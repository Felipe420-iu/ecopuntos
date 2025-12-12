import hashlib
import json
import time
from django.utils import timezone
from django.http import JsonResponse
from django.shortcuts import redirect
from django.contrib.auth import logout
from django.utils.crypto import get_random_string
from .models import SesionUsuario, IntentoAcceso, Notificacion, Configuracion
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from datetime import timedelta
import ipaddress

class SecurityManager:
    """Clase para manejar la seguridad de sesiones y validación de dispositivos"""
    
    @staticmethod
    def generate_device_id(request):
        """Genera un ID único para el dispositivo basado en User-Agent y otros factores"""
        user_agent = request.META.get('HTTP_USER_AGENT', '')
        accept_language = request.META.get('HTTP_ACCEPT_LANGUAGE', '')
        accept_encoding = request.META.get('HTTP_ACCEPT_ENCODING', '')
        
        # Crear un fingerprint del dispositivo
        device_string = f"{user_agent}|{accept_language}|{accept_encoding}"
        return hashlib.sha256(device_string.encode()).hexdigest()
    
    @staticmethod
    def generate_session_token():
        """Genera un token único para la sesión"""
        return get_random_string(64)
    
    @staticmethod
    def get_client_ip(request):
        """Obtiene la IP real del cliente"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip
    
    @staticmethod
    def create_secure_session(request, user):
        """Crea una sesión segura para el usuario"""
        try:
            device_id = SecurityManager.generate_device_id(request)
            token = SecurityManager.generate_session_token()
            ip_address = SecurityManager.get_client_ip(request)
            user_agent = request.META.get('HTTP_USER_AGENT', '')
            
            # Invalidar todas las sesiones activas del usuario (una sesión por usuario)
            SesionUsuario.objects.filter(usuario=user, activa=True).update(activa=False)
            
            # Expiración de sesión (configurable)
            timeout_seconds = SecurityManager._get_timeout_seconds(user.role)
            expiration = timezone.now() + timedelta(seconds=timeout_seconds)
            
            # Crear la sesión
            session = SesionUsuario.objects.create(
                usuario=user,
                token_sesion=token,
                dispositivo_id=device_id,
                ip_address=ip_address,
                user_agent=user_agent,
                fecha_expiracion=expiration
            )
            
            # Guardar datos necesarios en la sesión de Django (clave estándar 'session_token')
            request.session['session_token'] = token
            request.session['device_id'] = device_id

            # Retornar el token como string (las vistas esperan un token)
            return token
        except Exception as e:
            print(f"Error creating secure session: {str(e)}")
            # En caso de error, retornar un diccionario vacío pero válido
            return {
                'token': None,
                'device_id': None
            }
    
    @staticmethod
    def validate_session(request):
        """Valida la sesión actual del usuario"""
        if not request.user.is_authenticated:
            return False, "Usuario no autenticado"
        
        # No validar sesiones para superusuarios de Django
        if request.user.is_superuser:
            return True, "Superusuario válido"
        
        session_token = request.session.get('session_token') or request.session.get('secure_token')
        device_id = request.session.get('device_id')

        if not session_token or not device_id:
            return False, "Token de sesión no encontrado"

        try:
            session = SesionUsuario.objects.get(
                token_sesion=session_token,
                usuario=request.user,
                activa=True
            )
        except SesionUsuario.DoesNotExist:
            SecurityManager.log_access_attempt(request, 'token_invalido')
            return False, "Sesión no válida"
        
        # Verificar expiración
        if session.is_expired():
            session.activa = False
            session.save()
            SecurityManager.log_access_attempt(request, 'sesion_expirada')
            return False, "Sesión expirada"
        
        # Verificar dispositivo
        current_device_id = SecurityManager.generate_device_id(request)
        if session.dispositivo_id != current_device_id:
            SecurityManager.log_access_attempt(request, 'dispositivo_no_autorizado')
            return False, "Dispositivo no autorizado"
        
        # Verificar IP - BLOQUEAR acceso desde IP diferente
        current_ip = SecurityManager.get_client_ip(request)
        if session.ip_address != current_ip:
            SecurityManager.log_access_attempt(request, 'ip_diferente')
            # Crear notificación de seguridad
            SecurityManager.create_security_notification(
                session.usuario, 
                f"Intento de acceso detectado desde IP {current_ip}. Tu sesión fue iniciada desde {session.ip_address}. Si no fuiste tú, cambia tu contraseña inmediatamente."
            )
            # Invalidar la sesión por seguridad
            session.activa = False
            session.save()
            return False, f"Acceso denegado: IP no autorizada. Sesión iniciada desde {session.ip_address}, intento desde {current_ip}"
        
        # Actualizar última actividad y extender expiración según configuración
        session.ultima_actividad = timezone.now()
        timeout_seconds = SecurityManager._get_timeout_seconds(session.usuario.role)
        session.fecha_expiracion = timezone.now() + timedelta(seconds=timeout_seconds)
        session.save()
        
        return True, "Sesión válida"
    
    @staticmethod
    def log_access_attempt(request, motivo):
        """Registra un intento de acceso no autorizado"""
        ip_address = SecurityManager.get_client_ip(request)
        user_agent = request.META.get('HTTP_USER_AGENT', '')
        url_intento = request.build_absolute_uri()
        
        IntentoAcceso.objects.create(
            ip_address=ip_address,
            user_agent=user_agent,
            url_intento=url_intento,
            motivo=motivo
        )
    
    @staticmethod
    def invalidate_session(request):
        """Invalida la sesión actual del usuario"""
        # Esta función admite tanto `request` (HttpRequest) como `token` (str)
        try:
            from django.http import HttpRequest
        except Exception:
            HttpRequest = None

        # Si se pasó un request
        if HttpRequest and isinstance(request, HttpRequest):
            session_token = request.session.get('session_token') or request.session.get('secure_token')
            if session_token:
                try:
                    session = SesionUsuario.objects.get(token_sesion=session_token)
                    session.activa = False
                    session.save()
                except SesionUsuario.DoesNotExist:
                    pass

            # Limpiar sesión de Django
            request.session.flush()
            return True

        # Si se pasó un token (string)
        try:
            token = str(request)
            ses = SesionUsuario.objects.filter(token_sesion=token)
            if ses.exists():
                ses.update(activa=False)
                return True
        except Exception:
            pass

        return False
    
    @staticmethod
    def invalidate_all_user_sessions(user):
        """Invalida todas las sesiones activas de un usuario específico"""
        SesionUsuario.objects.filter(usuario=user, activa=True).update(activa=False)
        return True
    
    @staticmethod
    def get_active_sessions_count(user):
        """Obtiene el número de sesiones activas de un usuario"""
        return SesionUsuario.objects.filter(
            usuario=user,
            activa=True
        ).count()
    
    @staticmethod
    def cleanup_expired_sessions():
        """Limpia todas las sesiones expiradas"""
        expired_sessions = SesionUsuario.objects.filter(
            fecha_expiracion__lt=timezone.now(),
            activa=True
        )
        expired_sessions.update(activa=False)
        return expired_sessions.count()
    
    @staticmethod
    def cleanup_inactive_sessions():
        """
        Limpia sesiones inactivas con timeouts diferenciados:
        - Administradores: 10 minutos
        - Usuarios regulares: 15 minutos
        """
        from django.conf import settings
        import logging
        
        logger = logging.getLogger(__name__)
        
        # Limpiar sesiones de administradores (según configuración)
        admin_timeout = SecurityManager._get_timeout_seconds('admin')
        admin_cutoff = timezone.now() - timedelta(seconds=admin_timeout)
        admin_sessions = SesionUsuario.objects.filter(
            usuario__role='admin',
            ultima_actividad__lt=admin_cutoff,
            activa=True
        )
        admin_count = admin_sessions.count()
        admin_sessions.update(activa=False)
        
        # Limpiar sesiones de usuarios regulares (según configuración)
        user_timeout = SecurityManager._get_timeout_seconds('user')
        user_cutoff = timezone.now() - timedelta(seconds=user_timeout)
        user_sessions = SesionUsuario.objects.filter(
            ultima_actividad__lt=user_cutoff,
            activa=True
        ).exclude(usuario__role='admin')
        user_count = user_sessions.count()
        user_sessions.update(activa=False)
        
        total_count = admin_count + user_count
        logger.info(f'Limpiadas {total_count} sesiones inactivas (Admins: {admin_count}, Usuarios: {user_count})')
        return total_count
    
    @staticmethod
    def get_active_sessions_for_monitoring():
        """Obtiene todas las sesiones activas para el monitor de seguridad"""
        return SesionUsuario.objects.filter(
            activa=True
        ).select_related('usuario').order_by('-ultima_actividad')
    
    @staticmethod
    def force_logout_session(session_id):
        """Fuerza el cierre de una sesión específica"""
        try:
            session = SesionUsuario.objects.get(id=session_id, activa=True)
            session.activa = False
            session.save()
            # Crear notificación y notificar via Channels al usuario afectado
            message = f"Tu sesión ha sido cerrada por un administrador. Si no fuiste tú, por favor cambia tu contraseña." 
            notif = SecurityManager.create_security_notification(session.usuario, message)

            try:
                channel_layer = get_channel_layer()
                notification_payload = {
                    'id': notif.id if notif else None,
                    'titulo': 'Sesión cerrada por administrador',
                    'mensaje': message,
                    'tipo': 'session_closed',
                    'fecha_creacion': timezone.now().isoformat(),
                    'leida': False
                }
                async_to_sync(channel_layer.group_send)(
                    f'notificaciones_{session.usuario.id}',
                    {
                        'type': 'notification_message',
                        'notification': notification_payload
                    }
                )
            except Exception:
                # No interrumpir el flujo si Channels no está disponible
                pass

            return True, f"Sesión de {session.usuario.username} cerrada exitosamente"
        except SesionUsuario.DoesNotExist:
            return False, "Sesión no encontrada o ya cerrada"
    
    @staticmethod
    def create_security_notification(user, message):
        """Crea una notificación de seguridad para el usuario"""
        from .models import Notificacion
        notif = Notificacion.objects.create(
            usuario=user,
            mensaje=message,
            titulo='Alerta de seguridad',
            tipo='sistema'
        )
        return notif

    @staticmethod
    def _get_timeout_seconds(role):
        """Obtiene el timeout de sesión en segundos desde Configuracion o valores por defecto."""
        try:
            if role == 'admin':
                key = 'admin_session_timeout'
            else:
                key = 'user_session_timeout'

            cfg = Configuracion.objects.filter(categoria='sesiones', nombre=key).first()
            if cfg and cfg.valor:
                # Intentar parsear como entero (segundos)
                try:
                    return int(cfg.valor)
                except ValueError:
                    # Si el valor se guarda en minutos, convertir a segundos
                    try:
                        return int(float(cfg.valor) * 60)
                    except Exception:
                        pass
        except Exception:
            pass

        # Valores por defecto (segundos)
        return 600 if role == 'admin' else 900

def require_secure_session(view_func):
    """Decorador para requerir sesión segura"""
    def wrapper(request, *args, **kwargs):
        if not request.user.is_authenticated:
            return redirect('iniciosesion')
        
        is_valid, message = SecurityManager.validate_session(request)
        if not is_valid:
            SecurityManager.invalidate_session(request)
            logout(request)
            return redirect('iniciosesion')
        
        return view_func(request, *args, **kwargs)
    return wrapper

# Clase para manejar autenticación de dos factores por email
class TwoFactorManager:
    """Clase para manejar autenticación de dos factores por email"""
    
    @staticmethod
    def generate_verification_code():
        """Genera un código de verificación de 6 dígitos"""
        import random
        return str(random.randint(100000, 999999))
    
    @staticmethod
    def send_verification_email(user):
        """Envía email con código de verificación"""
        from django.core.mail import send_mail
        from django.template.loader import render_to_string
        from django.conf import settings
        from django.utils import timezone
        from datetime import timedelta
        
        # Generar código y configurar expiración
        codigo = TwoFactorManager.generate_verification_code()
        user.codigo_verificacion = codigo
        user.codigo_verificacion_expira = timezone.now() + timedelta(minutes=10)
        user.intentos_verificacion = 0  # Resetear intentos
        user.save()
        
        # Preparar email
        subject = f'Verifica tu cuenta en Eco Puntos - Código: {codigo}'
        
        # Mensaje HTML
        html_message = f'''
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
            <div style="background: linear-gradient(135deg, #43a047 0%, #7cb342 100%); padding: 30px; border-radius: 10px; text-align: center; color: white;">
                <h2>¡Bienvenido a Eco Puntos!</h2>
                <p style="font-size: 18px; margin: 20px 0;">Tu código de verificación es:</p>
                <div style="background: white; color: #43a047; font-size: 32px; font-weight: bold; padding: 20px; border-radius: 10px; margin: 20px 0; letter-spacing: 5px;">
                    {codigo}
                </div>
                <p style="font-size: 14px; opacity: 0.9;">Este código expira en 10 minutos</p>
            </div>
            <div style="padding: 20px; text-align: center; color: #666;">
                <p>Si no solicitaste este registro, puedes ignorar este email.</p>
                <p style="font-size: 12px;">© 2025 Eco Puntos - Cuidando el planeta juntos</p>
            </div>
        </div>
        '''
        
        # Mensaje de texto plano
        message = f'''
¡Hola {user.username}!

Gracias por registrarte en Eco Puntos.

Tu código de verificación es: {codigo}

Este código expira en 10 minutos.

Si no solicitaste este registro, puedes ignorar este email.

¡Bienvenido a la comunidad Eco Puntos!
        '''
        
        try:
            # Verificar configuración de email
            if not settings.EMAIL_HOST_USER or not settings.EMAIL_HOST_PASSWORD:
                error_msg = "EMAIL_HOST_USER o EMAIL_HOST_PASSWORD no configurados en settings"
                print(f"❌ {error_msg}")
                return False, error_msg
            
            print(f"📧 Intentando enviar email a {user.email}")
            print(f"   FROM: {settings.DEFAULT_FROM_EMAIL}")
            print(f"   SMTP: {settings.EMAIL_HOST}:{settings.EMAIL_PORT}")
            
            send_mail(
                subject=subject,
                message=message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[user.email],
                html_message=html_message,
                fail_silently=False
            )
            
            print(f"✅ Email enviado exitosamente a {user.email}")
            return True, "Email enviado correctamente"
            
        except Exception as e:
            import traceback
            error_detallado = traceback.format_exc()
            print(f"❌ Error enviando email a {user.email}:")
            print(f"   Tipo: {type(e).__name__}")
            print(f"   Mensaje: {str(e)}")
            print(f"   Traceback:\n{error_detallado}")
            return False, f"Error enviando email: {str(e)}"
    
    @staticmethod
    def verify_code(user, codigo_ingresado):
        """Verifica el código ingresado por el usuario"""
        from django.utils import timezone
        
        # Verificar si está bloqueado temporalmente
        if user.verificacion_bloqueada_hasta and user.verificacion_bloqueada_hasta > timezone.now():
            tiempo_restante = user.verificacion_bloqueada_hasta - timezone.now()
            minutos_restantes = int(tiempo_restante.total_seconds() / 60)
            return False, f"Cuenta bloqueada temporalmente. Intenta en {minutos_restantes} minutos."
        
        # Verificar si el código ha expirado
        if not user.codigo_verificacion_expira or user.codigo_verificacion_expira < timezone.now():
            return False, "El código de verificación ha expirado. Solicita uno nuevo."
        
        # Verificar el código
        if user.codigo_verificacion != codigo_ingresado:
            user.intentos_verificacion += 1
            
            # Bloquear temporalmente después de 3 intentos fallidos
            if user.intentos_verificacion >= 3:
                user.verificacion_bloqueada_hasta = timezone.now() + timedelta(minutes=15)
                user.save()
                return False, "Demasiados intentos fallidos. Cuenta bloqueada por 15 minutos."
            
            user.save()
            intentos_restantes = 3 - user.intentos_verificacion
            return False, f"Código incorrecto. Te quedan {intentos_restantes} intentos."
        
        # Código correcto - activar cuenta
        user.email_verificado = True
        user.is_active = True
        user.codigo_verificacion = None
        user.codigo_verificacion_expira = None
        user.intentos_verificacion = 0
        user.verificacion_bloqueada_hasta = None
        user.save()
        
        return True, "¡Email verificado correctamente! Ya puedes iniciar sesión."
    
    @staticmethod
    def can_resend_code(user):
        """Verifica si se puede reenviar el código (cooldown de 1 minuto)"""
        from django.utils import timezone
        from datetime import timedelta
        
        if not hasattr(user, '_ultimo_envio_codigo'):
            return True, "Puedes solicitar un nuevo código"
        
        tiempo_transcurrido = timezone.now() - user._ultimo_envio_codigo
        if tiempo_transcurrido < timedelta(minutes=1):
            segundos_restantes = 60 - int(tiempo_transcurrido.total_seconds())
            return False, f"Espera {segundos_restantes} segundos antes de solicitar otro código"
        
        return True, "Puedes solicitar un nuevo código"