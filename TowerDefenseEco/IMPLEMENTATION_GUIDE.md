# 🚀 **GUÍA PASO A PASO - IMPLEMENTACIÓN COMPLETA**
# EcoPuntos Tower Defense - Godot 4.5.1

## 📋 **PRERREQUISITOS**

### Software Necesario
- ✅ Godot 4.5.1 (descargado e instalado)
- ✅ Proyecto EcoPuntos Django funcionando (localhost:8000 o Railway)
- ✅ Editor de código (VS Code recomendado)
- ✅ Git (para control de versiones)

### Conocimientos Básicos
- 🎮 Fundamentos de Godot (escenas, nodos, signals)
- 📜 GDScript básico (sintaxis, clases, herencia)
- 🌐 APIs REST (HTTP requests, JSON)
- 🐍 Django/Python (para integración con EcoPuntos)

---

## 🏗️ **PASO 1: CONFIGURACIÓN INICIAL DEL PROYECTO**

### 1.1 Crear Proyecto en Godot
```bash
1. Abrir Godot 4.5.1
2. Crear Nuevo Proyecto → "TowerDefenseEco"
3. Seleccionar carpeta: TowerDefenseEco/
4. Crear y Editar
```

### 1.2 Copiar Estructura de Archivos
```bash
# Copiar todos los archivos .gd generados a su ubicación correspondiente:
TowerDefenseEco/
├── scripts/         ← Copiar todos los .gd aquí
├── scenes/          ← Crear escenas .tscn aquí  
├── assets/          ← Agregar sprites y audio aquí
└── data/            ← Configuraciones JSON aquí
```

### 1.3 Configurar project.godot
```bash
# Reemplazar project.godot con el archivo generado
# Esto configura:
- Autloads (GameManager, Constants, etc.)
- Controles de entrada
- Capas de física
- Configuración de pantalla
```

---

## 🎨 **PASO 2: CREAR ESCENAS PRINCIPALES**

### 2.1 Escena Principal (Main.tscn)
```bash
# Estructura de nodos:
Main (Node2D)
├── GameManager (GameManager) - Script: scripts/core/GameManager.gd
├── LevelManager (LevelManager)
├── WaveManager (WaveManager) - Script: scripts/core/WaveManager.gd  
├── TowerManager (TowerManager)
├── EnemyManager (EnemyManager)
├── UIManager (UIManager)
├── AudioManager (AudioManager)
├── EcoPuntosAPI (EcoPuntosAPI) - Script: scripts/api/EcoPuntosAPI.gd
└── HUD (HUD) - Script: scripts/ui/HUD.gd
```

### 2.2 Escena de Nivel (GameLevel.tscn)
```bash
GameLevel (Node2D) - Group: "level"
├── Background (Sprite2D)
├── EnemyPath (Path2D)
│   └── PathFollow2D
├── TowerSpots (Node2D)
│   ├── TowerSpot1 (TowerSpot) - Script: scripts/gameplay/environment/TowerSpot.gd
│   ├── TowerSpot2 (TowerSpot)
│   └── TowerSpot3 (TowerSpot)
├── Towers (Node2D)
├── Enemies (Node2D)
├── Projectiles (Node2D)
└── Effects (Node2D)
```

### 2.3 Escena de Enemigo Base (BaseEnemy.tscn)
```bash
BaseEnemy (CharacterBody2D) - Script: scripts/gameplay/enemies/BaseEnemy.gd
├── Sprite2D
├── CollisionShape2D
├── HealthBar (ProgressBar)
├── HitParticles (CPUParticles2D)
├── DeathParticles (CPUParticles2D)
├── AnimationPlayer
└── StatusEffects (Node2D)
```

### 2.4 Escena de Torre Base (BaseTower.tscn)
```bash
BaseTower (Node2D) - Script: scripts/gameplay/towers/BaseTower.gd
├── Sprite2D
├── Barrel (Sprite2D)
├── RangeIndicator (Sprite2D)
├── MuzzleFlash (CPUParticles2D)
├── DetectionArea (Area2D)
│   └── CollisionShape2D
├── FireTimer (Timer)
└── UpgradeIndicator (Sprite2D)
```

### 2.5 Escena de Proyectil Base (BaseProjectile.tscn)
```bash
BaseProjectile (RigidBody2D) - Script: scripts/gameplay/projectiles/BaseProjectile.gd
├── Sprite2D
├── CollisionShape2D
├── TrailParticles (CPUParticles2D)
├── ImpactParticles (CPUParticles2D)
├── SplashParticles (CPUParticles2D)
├── HitArea (Area2D)
│   └── CollisionShape2D
└── LifetimeTimer (Timer)
```

---

## 🎮 **PASO 3: IMPLEMENTAR GAMEPLAY BÁSICO**

### 3.1 Configurar Managers
```bash
# En Main.tscn:
1. Agregar GameManager como nodo
2. Asignar script: scripts/core/GameManager.gd
3. Repetir para WaveManager, etc.
4. Configurar Groups para cada manager
```

### 3.2 Crear Enemigos Específicos
```bash
# PlasticWaste.tscn (hereda de BaseEnemy.tscn)
1. Scene → New Inherited Scene → BaseEnemy.tscn
2. Cambiar script a: scripts/gameplay/enemies/PlasticWaste.gd  
3. Configurar sprite con color amarillo
4. Ajustar stats: HP=80, Speed=90, Reward=15
5. Repetir para Glass, Paper, Metal
```

### 3.3 Crear Torres Específicas
```bash
# PlasticTower.tscn (hereda de BaseTower.tscn)
1. Scene → New Inherited Scene → BaseTower.tscn
2. Cambiar script a: scripts/gameplay/towers/PlasticTower.gd
3. Configurar sprite con color verde/amarillo
4. Ajustar stats: Damage=30, Range=110, Cost=60
5. Repetir para Glass, Paper, Metal
```

### 3.4 Configurar Path2D
```bash
# En GameLevel.tscn:
1. Seleccionar EnemyPath (Path2D)
2. Usar herramienta de Curve para dibujar camino
3. Crear ruta desde borde izquierdo al derecho
4. Agregar curvas y obstáculos interesantes
```

---

## 🌐 **PASO 4: INTEGRAR API ECOPUNTOS**

### 4.1 Configurar Conexión API
```bash
# En Main.tscn, nodo EcoPuntosAPI:
1. Asignar script: scripts/api/EcoPuntosAPI.gd
2. En Inspector, configurar:
   - base_url = "http://localhost:8000/api/" (desarrollo)
   - base_url = "https://tu-app.railway.app/api/" (producción)
```

### 4.2 Conectar Signals
```bash
# En GameManager.gd, función _setup_connections():
eco_points_api.authentication_changed.connect(_on_auth_changed)
eco_points_api.points_updated.connect(_on_points_updated)
eco_points_api.api_error.connect(_on_api_error)
```

### 4.3 Implementar Login
```bash
# Crear LoginScreen.tscn:
LoginScreen (Control)
├── UsernameField (LineEdit)
├── PasswordField (LineEdit) - secret = true
├── LoginButton (Button)
├── StatusLabel (Label)
└── OfflineButton (Button)

# Script: scripts/ui/LoginScreen.gd
func _on_login_button_pressed():
    var username = username_field.text
    var password = password_field.text
    eco_points_api.login(username, password)
```

---

## 💰 **PASO 5: SISTEMA DE PUNTOS Y RECOMPENSAS**

### 5.1 Configurar Envío de Puntos
```bash
# En GameManager.gd, función _victory():
var game_results = {
    "level": current_level,
    "score": score,
    "enemies_defeated": enemies_defeated,
    "time_played": statistics["time_played"],
    "materials_recycled": statistics
}
eco_points_api.submit_game_results(game_results)
```

### 5.2 Mostrar Puntos en UI
```bash
# En HUD.gd:
func _on_points_updated(points_data: Dictionary):
    var total_eco_points = 0
    for material in points_data:
        total_eco_points += points_data[material]
    
    eco_points_label.text = "EcoPuntos: " + str(total_eco_points)
```

---

## 🎨 **PASO 6: ASSETS Y DISEÑO VISUAL**

### 6.1 Sprites Básicos (Placeholder)
```bash
assets/sprites/
├── towers/
│   ├── plastic_tower.png (32x32, color verde-amarillo)
│   ├── glass_tower.png (32x32, color azul claro)  
│   ├── paper_tower.png (32x32, color marrón)
│   └── metal_tower.png (32x32, color gris metálico)
├── enemies/
│   ├── plastic_waste.png (24x24, amarillo)
│   ├── glass_waste.png (24x24, azul)
│   ├── paper_waste.png (24x24, marrón)
│   └── metal_waste.png (24x24, gris)
└── ui/
    ├── icon.png (128x128, logo EcoPuntos)
    └── cursor.png (32x32, cursor personalizado)
```

### 6.2 Audio Básico
```bash
assets/audio/
├── sfx/
│   ├── tower_fire.ogg
│   ├── enemy_hit.ogg
│   ├── enemy_death.ogg
│   └── wave_complete.ogg
└── music/
    ├── menu_music.ogg
    └── game_music.ogg
```

### 6.3 Tema UI
```bash
# assets/themes/eco_theme.tres
- Colores EcoPuntos: Verde (#20CC30), Azul (#1060E0)
- Fuente personalizada para UI
- Botones con esquinas redondeadas
- Barras de progreso con gradiente
```

---

## 🧪 **PASO 7: TESTING Y DEBUG**

### 7.1 Testing Básico
```bash
# Verificar cada sistema:
1. Ejecutar Main.tscn
2. Verificar spawning de enemigos
3. Probar colocación de torres
4. Verificar disparo de proyectiles
5. Confirmar detección de colisiones
6. Probar conexión API (con Django corriendo)
```

### 7.2 Debug Console
```bash
# Agregar debug commands en GameManager.gd:
func _input(event):
    if OS.is_debug_build():
        if event.is_action_pressed("ui_accept") and Input.is_action_pressed("ui_cancel"):
            _debug_add_money(100)
        if event.is_action_pressed("ui_up"):
            _debug_skip_wave()
        if event.is_action_pressed("ui_down"):
            _debug_spawn_enemy()
```

### 7.3 Logs Estructurados
```bash
# En cada script principal, usar print con emojis:
print("🎮 GameManager initialized")
print("👾 Enemy spawned: ", enemy_name)
print("🗼 Tower placed at: ", position)
print("💰 Points earned: ", points)
print("🌐 API connected: ", is_connected)
```

---

## 🚀 **PASO 8: OPTIMIZACIÓN Y PULIMIENTO**

### 8.1 Pool de Objetos
```bash
# Para proyectiles y efectos:
# scripts/utils/ObjectPool.gd
class_name ObjectPool extends Node

var pools = {}

func get_object(scene_path: String):
    if not pools.has(scene_path):
        pools[scene_path] = []
    
    if pools[scene_path].is_empty():
        return load(scene_path).instantiate()
    else:
        return pools[scene_path].pop_back()

func return_object(obj, scene_path: String):
    obj.reset()  # Método para resetear estado
    pools[scene_path].append(obj)
```

### 8.2 Configuración de Performance
```bash
# En project.godot:
[rendering]
renderer/rendering_method="forward_plus"
2d/use_pixel_snap=true
textures/canvas_textures/default_texture_filter=1

[physics]
2d/physics_ticks_per_second=120
common/enable_pause_aware_picking=true
```

### 8.3 Límites de Rendimiento  
```bash
# En Constants.gd:
const MAX_PROJECTILES_ON_SCREEN = 100
const MAX_ENEMIES_ON_SCREEN = 50
const MAX_PARTICLES_PER_EFFECT = 50

# Implementar en managers correspondientes
```

---

## 📦 **PASO 9: EXPORTACIÓN Y DESPLIEGUE**

### 9.1 Configurar Export Presets
```bash
1. Project → Export
2. Add Export Template → Web
3. Configure:
   - Name: "EcoPuntos Tower Defense Web"
   - Export Path: "builds/web/index.html"
   - Features: Thread Support = false (para web)
```

### 9.2 Build para Múltiples Plataformas
```bash
# Windows:
- Platform: Windows Desktop
- Architecture: x86_64
- Features: Console = false

# Android:
- Platform: Android
- Min API Level: 21
- Target API Level: 33
- Permissions: INTERNET, NETWORK_STATE

# Web:
- Platform: Web  
- Threads: false
- SharedArrayBuffer: false
```

### 9.3 Configuración para Producción
```bash
# En scripts/api/EcoPuntosAPI.gd:
# Cambiar URL base para producción:
var base_url = "https://tu-app-ecopuntos.railway.app/api/"

# Habilitar HTTPS
# Configurar CORS en Django
```

---

## 🔧 **PASO 10: INTEGRACIÓN AVANZADA**

### 10.1 Sistema de Achievements
```bash
# scripts/core/AchievementManager.gd
extends Node
class_name AchievementManager

var achievements = {
    "first_win": false,
    "plastic_master": false,
    "eco_warrior": false
}

func check_achievement(type: String, value: int):
    match type:
        "level_complete":
            if not achievements["first_win"]:
                unlock_achievement("first_win")
        "plastic_recycled":
            if value >= 100 and not achievements["plastic_master"]:
                unlock_achievement("plastic_master")
```

### 10.2 Analytics y Métricas
```bash
# scripts/utils/Analytics.gd
extends Node

func track_event(event_name: String, properties: Dictionary):
    # Enviar a EcoPuntos API para analytics
    var data = {
        "event": event_name,
        "properties": properties,
        "timestamp": Time.get_time_dict_from_system()
    }
    # POST a /api/analytics/track/
```

### 10.3 Sistema de Configuraciones
```bash
# scripts/core/SettingsManager.gd
extends Node

var settings = {
    "master_volume": 1.0,
    "sfx_volume": 1.0,
    "music_volume": 0.7,
    "auto_save": true,
    "graphics_quality": "high"
}

func save_settings():
    var file = FileAccess.open("user://settings.dat", FileAccess.WRITE)
    file.store_string(JSON.stringify(settings))
    file.close()
```

---

## 🎯 **CHECKLIST FINAL**

### Funcionalidad Core
- ✅ Enemigos se mueven por el path
- ✅ Torres disparan a enemigos en rango
- ✅ Proyectiles causan daño y efectos
- ✅ Sistema de vidas y dinero funciona
- ✅ Oleadas se generan correctamente
- ✅ Victory/Game Over se detecta

### Integración EcoPuntos
- ✅ Login/logout funcional
- ✅ Puntos se envían al completar niveles
- ✅ Conexión online/offline manejada
- ✅ Errores de API manejados graciosamente
- ✅ Cache local para datos offline

### Polish y UX
- ✅ UI responsiva y clara
- ✅ Efectos visuales funcionan
- ✅ Audio implementado
- ✅ Controles intuitivos
- ✅ Feedback visual para acciones
- ✅ Mensajes de estado claros

### Performance
- ✅ FPS estable en 60fps
- ✅ Sin memory leaks
- ✅ Carga rápida de escenas
- ✅ Pool de objetos para proyectiles
- ✅ Límites de entidades en pantalla

---

## 🆘 **TROUBLESHOOTING COMÚN**

### Error: "Scene not found"
```bash
# Verificar que todas las rutas en preload() existan:
preload("res://scenes/gameplay/enemies/PlasticWaste.tscn")
# Crear escenas faltantes o ajustar rutas
```

### Error: "HTTPRequest failed"
```bash
# Verificar que Django esté corriendo
# Verificar URL de API en Constants.gd
# Verificar configuración CORS en Django
# Probar endpoints en Postman primero
```

### Error: "Script class not found"
```bash
# Verificar que class_name esté definido en scripts
# Asegurar que scripts estén asignados a nodos correctos
# Verificar herencia de clases (extends BaseEnemy)
```

### Performance Issues
```bash
# Reducir MAX_PROJECTILES_ON_SCREEN
# Optimizar Path2D (menos puntos de control)
# Usar object pooling para proyectiles
# Reducir emisión de partículas
```

---

## 🎉 **¡PROYECTO COMPLETADO!**

Has creado un Tower Defense profesional integrado con EcoPuntos que incluye:

- 🏗️ **Arquitectura modular** con managers separados
- 🎮 **Gameplay sólido** con torres, enemigos y proyectiles
- 🌐 **Integración API** con sistema de puntos sincronizado
- 🎨 **UI pulida** con tema EcoPuntos
- 📱 **Multi-plataforma** (PC, Web, Móvil)
- 🔧 **Sistema extensible** para agregar más funcionalidades

**¡Ahora puedes expandir el juego con nuevas torres, enemigos, efectos y conexiones más profundas con el ecosistema EcoPuntos!** 🚀🌱