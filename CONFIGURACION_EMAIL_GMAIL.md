# 📧 Configuración de Gmail SMTP para EcoPuntos

## 🎯 Objetivo
Configurar el envío de emails reales usando Gmail SMTP en tu aplicación Django desplegada en Railway.

---

## 📋 PASO 1: Crear/Usar Cuenta de Gmail

### Opción A: Crear nueva cuenta (Recomendado)
1. Ve a https://accounts.google.com/signup
2. Crea una cuenta específica para tu aplicación, por ejemplo:
   - **Email**: `ecopuntos.noreply@gmail.com`
   - **Contraseña**: (guarda esta contraseña)

### Opción B: Usar cuenta existente
Puedes usar tu cuenta actual de Gmail, pero es mejor crear una específica para la app.

---

## 🔐 PASO 2: Habilitar "Contraseñas de Aplicación"

### 2.1 Habilitar Verificación en 2 Pasos
1. Ve a tu cuenta de Google: https://myaccount.google.com
2. Selecciona **Seguridad** en el menú lateral
3. En "Cómo inicias sesión en Google", haz clic en **Verificación en dos pasos**
4. Sigue los pasos para habilitarla (necesitarás tu teléfono)

### 2.2 Generar Contraseña de Aplicación
1. Una vez habilitada la verificación en 2 pasos, ve a: https://myaccount.google.com/apppasswords
2. En "Selecciona la app", elige **Correo**
3. En "Selecciona el dispositivo", elige **Otro (nombre personalizado)**
4. Escribe: `EcoPuntos Railway`
5. Haz clic en **Generar**
6. **¡IMPORTANTE!** Copia la contraseña de 16 caracteres que aparece (ejemplo: `abcd efgh ijkl mnop`)
7. **Guarda esta contraseña**, la necesitarás para Railway

---

## ⚙️ PASO 3: Configurar Variables en Railway

1. Ve a tu proyecto en Railway: https://railway.app
2. Selecciona tu servicio **ecopuntos1.0**
3. Ve a la pestaña **Variables**
4. Agrega las siguientes variables:

### Variables a Agregar:

```bash
EMAIL_HOST_USER=tu-email@gmail.com
EMAIL_HOST_PASSWORD=abcd efgh ijkl mnop
DEFAULT_FROM_EMAIL=EcoPuntos <tu-email@gmail.com>
```

**Ejemplo con valores reales:**
```bash
EMAIL_HOST_USER=ecopuntos.noreply@gmail.com
EMAIL_HOST_PASSWORD=abcd efgh ijkl mnop
DEFAULT_FROM_EMAIL=EcoPuntos <ecopuntos.noreply@gmail.com>
```

### ⚠️ IMPORTANTE:
- **EMAIL_HOST_PASSWORD** debe ser la contraseña de aplicación de 16 caracteres (con o sin espacios)
- **NO** uses tu contraseña normal de Gmail
- Si la contraseña tiene espacios, puedes dejarlos o quitarlos (ambos funcionan)

---

## 🚀 PASO 4: Hacer Deploy

Después de configurar las variables en Railway:

```bash
# En tu terminal local
git add proyecto2023/settings.py
git commit -m "Configurar Gmail SMTP para envío de emails reales"
git push origin master
```

Railway detectará el push y hará un nuevo deploy automáticamente.

---

## ✅ PASO 5: Verificar que Funciona

### 5.1 Verificar en Deploy Logs
1. Ve a Railway → tu servicio → **Deploy Logs**
2. Ya NO deberías ver el warning: `WARNING Supabase no está configurado correctamente`
3. Busca que no haya errores de SMTP

### 5.2 Probar Registro
1. Ve a tu app: https://ecopuntos10-production.up.railway.app/registrate
2. Intenta registrar un usuario con tu email real
3. **Deberías recibir** un email de verificación en tu bandeja de entrada

### 5.3 Verificar en Gmail
1. Si usaste una cuenta nueva de Gmail para la app
2. Revisa los **Mensajes enviados** de esa cuenta
3. Deberías ver los emails enviados desde tu aplicación

---

## 🔧 Configuración Técnica (Ya está en settings.py)

```python
# Configuración de Gmail SMTP
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'tu-email@gmail.com'  # De Railway
EMAIL_HOST_PASSWORD = 'contraseña-app'  # De Railway
DEFAULT_FROM_EMAIL = 'EcoPuntos <tu-email@gmail.com>'
EMAIL_TIMEOUT = 30
```

---

## 🐛 Troubleshooting

### Problema 1: "SMTPAuthenticationError"
**Causa**: Contraseña incorrecta o no es contraseña de aplicación
**Solución**:
- Verifica que uses la contraseña de aplicación (16 caracteres)
- No uses tu contraseña normal de Gmail
- Genera una nueva contraseña de aplicación

### Problema 2: "Network is unreachable"
**Causa**: Variables no configuradas en Railway
**Solución**:
- Verifica que `EMAIL_HOST_USER` y `EMAIL_HOST_PASSWORD` estén en Railway Variables
- Redeploy después de agregar las variables

### Problema 3: Email no llega
**Posibles causas**:
1. **Spam**: Revisa tu carpeta de spam
2. **Delay**: Gmail puede tardar 1-2 minutos
3. **Email incorrecto**: Verifica que el email de registro sea válido

### Problema 4: "Password incorrect"
**Solución**:
1. Genera una NUEVA contraseña de aplicación
2. Actualiza `EMAIL_HOST_PASSWORD` en Railway
3. Redeploy la aplicación

---

## 📊 Verificación en Railway

Después del deploy, en los logs deberías ver:

✅ **Correcto:**
```
Starting Gunicorn...
[INFO] Starting gunicorn...
[INFO] Booting worker with pid: 2
```

❌ **Incorrecto:**
```
WARNING Supabase no está configurado correctamente
SMTPAuthenticationError: (535, ...)
```

---

## 🎯 Checklist de Configuración

- [ ] Cuenta de Gmail creada o disponible
- [ ] Verificación en 2 pasos habilitada
- [ ] Contraseña de aplicación generada (16 caracteres)
- [ ] Variable `EMAIL_HOST_USER` agregada en Railway
- [ ] Variable `EMAIL_HOST_PASSWORD` agregada en Railway
- [ ] Variable `DEFAULT_FROM_EMAIL` agregada en Railway (opcional)
- [ ] Commit y push realizados
- [ ] Railway desplegó correctamente
- [ ] Prueba de registro exitosa
- [ ] Email recibido en bandeja de entrada

---

## 📝 Ejemplo Completo

### En Railway Variables:
```
EMAIL_HOST_USER=ecopuntos.noreply@gmail.com
EMAIL_HOST_PASSWORD=abcdefghijklmnop
DEFAULT_FROM_EMAIL=EcoPuntos <ecopuntos.noreply@gmail.com>
```

### Resultado:
- ✅ Los usuarios recibirán emails de verificación desde `ecopuntos.noreply@gmail.com`
- ✅ El nombre del remitente será "EcoPuntos"
- ✅ Los emails se enviarán inmediatamente

---

## 🔒 Seguridad

### ✅ Buenas Prácticas:
1. **Nunca** compartas tu contraseña de aplicación públicamente
2. **Nunca** hagas commit de las contraseñas en Git
3. Usa variables de entorno (Railway) siempre
4. Crea una cuenta Gmail específica para la app
5. Revoca contraseñas de aplicación que no uses

### ⚠️ Si comprometes la contraseña:
1. Ve a https://myaccount.google.com/apppasswords
2. Elimina la contraseña comprometida
3. Genera una nueva
4. Actualiza Railway con la nueva contraseña

---

## 📞 Enlaces Útiles

- **Cuenta de Google**: https://myaccount.google.com
- **Verificación en 2 pasos**: https://myaccount.google.com/signinoptions/two-step-verification
- **Contraseñas de Aplicación**: https://myaccount.google.com/apppasswords
- **Railway Dashboard**: https://railway.app/dashboard
- **Documentación Gmail SMTP**: https://support.google.com/mail/answer/7126229

---

## ✅ Resumen

1. **Crea cuenta Gmail** específica para tu app
2. **Habilita verificación en 2 pasos** en Google
3. **Genera contraseña de aplicación** (16 caracteres)
4. **Agrega variables en Railway**:
   - `EMAIL_HOST_USER`
   - `EMAIL_HOST_PASSWORD`
5. **Push a Git** para deployar
6. **Prueba el registro** y verifica que llegue el email

**¡Listo! Tu app ahora envía emails reales con Gmail SMTP. 📧✅**
