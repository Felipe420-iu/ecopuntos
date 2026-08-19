# EcoPuntos Tower Defense - Estructura del Proyecto

## 📁 Estructura de Carpetas (Estudio Profesional)

```
TowerDefenseEco/
├── project.godot                     # Configuración principal del proyecto
├── export_presets.cfg               # Configuración de exportación
├── README.md                        # Documentación del proyecto
│
├── 🎮 scenes/                       # Escenas principales del juego
│   ├── main/
│   │   ├── Main.tscn               # Escena principal del juego
│   │   ├── GameLevel.tscn          # Nivel de juego individual
│   │   └── GameOverScreen.tscn     # Pantalla de fin de juego
│   │
│   ├── ui/                         # Interfaces de usuario
│   │   ├── MainMenu.tscn           # Menú principal
│   │   ├── PauseMenu.tscn          # Menú de pausa
│   │   ├── HUD.tscn                # Interfaz del juego
│   │   ├── TowerShop.tscn          # Tienda de torres
│   │   ├── LoginScreen.tscn        # Pantalla de login EcoPuntos
│   │   └── VictoryScreen.tscn      # Pantalla de victoria
│   │
│   ├── gameplay/
│   │   ├── towers/                 # Torres del juego
│   │   │   ├── BaseTower.tscn      # Torre base (abstracta)
│   │   │   ├── PlasticTower.tscn   # Torre de plástico
│   │   │   ├── GlassTower.tscn     # Torre de vidrio
│   │   │   ├── PaperTower.tscn     # Torre de papel
│   │   │   └── MetalTower.tscn     # Torre de metal
│   │   │
│   │   ├── enemies/                # Enemigos
│   │   │   ├── BaseEnemy.tscn      # Enemigo base
│   │   │   ├── PlasticWaste.tscn   # Residuo de plástico
│   │   │   ├── GlassWaste.tscn     # Residuo de vidrio
│   │   │   ├── PaperWaste.tscn     # Residuo de papel
│   │   │   ├── MetalWaste.tscn     # Residuo de metal
│   │   │   └── BossWaste.tscn      # Jefe contaminante
│   │   │
│   │   ├── projectiles/            # Proyectiles
│   │   │   ├── BaseProjectile.tscn # Proyectil base
│   │   │   ├── RecycleBullet.tscn  # Bala de reciclaje
│   │   │   ├── CleanBeam.tscn      # Rayo de limpieza
│   │   │   └── EcoBomb.tscn        # Bomba ecológica
│   │   │
│   │   └── environment/            # Elementos del entorno
│   │       ├── Path.tscn           # Camino de enemigos
│   │       ├── TowerSpot.tscn      # Punto donde poner torres
│   │       └── Background.tscn     # Fondo del nivel
│   │
│   └── effects/                    # Efectos visuales
│       ├── Explosion.tscn          # Explosión
│       ├── RecycleEffect.tscn      # Efecto de reciclaje
│       └── ImpactEffect.tscn       # Efecto de impacto
│
├── 📜 scripts/                     # Scripts del juego
│   ├── core/                       # Sistema núcleo
│   │   ├── GameManager.gd          # Manager principal del juego
│   │   ├── LevelManager.gd         # Manager de niveles
│   │   ├── WaveManager.gd          # Manager de oleadas
│   │   ├── TowerManager.gd         # Manager de torres
│   │   ├── EnemyManager.gd         # Manager de enemigos
│   │   ├── UIManager.gd            # Manager de UI
│   │   ├── AudioManager.gd         # Manager de audio
│   │   └── SaveManager.gd          # Manager de guardado
│   │
│   ├── gameplay/
│   │   ├── towers/                 # Scripts de torres
│   │   │   ├── BaseTower.gd        # Torre base (abstracta)
│   │   │   ├── PlasticTower.gd     # Torre de plástico
│   │   │   ├── GlassTower.gd       # Torre de vidrio
│   │   │   ├── PaperTower.gd       # Torre de papel
│   │   │   └── MetalTower.gd       # Torre de metal
│   │   │
│   │   ├── enemies/                # Scripts de enemigos
│   │   │   ├── BaseEnemy.gd        # Enemigo base
│   │   │   ├── PlasticWaste.gd     # Residuo de plástico
│   │   │   ├── GlassWaste.gd       # Residuo de vidrio
│   │   │   ├── PaperWaste.gd       # Residuo de papel
│   │   │   ├── MetalWaste.gd       # Residuo de metal
│   │   │   └── BossWaste.gd        # Jefe contaminante
│   │   │
│   │   ├── projectiles/            # Scripts de proyectiles
│   │   │   ├── BaseProjectile.gd   # Proyectil base
│   │   │   ├── RecycleBullet.gd    # Bala de reciclaje
│   │   │   ├── CleanBeam.gd        # Rayo de limpieza
│   │   │   └── EcoBomb.gd          # Bomba ecológica
│   │   │
│   │   └── environment/            # Scripts del entorno
│   │       ├── TowerSpot.gd        # Punto de torre
│   │       └── WavePath.gd         # Camino de oleadas
│   │
│   ├── ui/                         # Scripts de interfaz
│   │   ├── MainMenu.gd             # Menú principal
│   │   ├── PauseMenu.gd            # Menú de pausa
│   │   ├── HUD.gd                  # Interfaz del juego
│   │   ├── TowerShop.gd            # Tienda de torres
│   │   ├── LoginScreen.gd          # Pantalla de login
│   │   ├── VictoryScreen.gd        # Pantalla de victoria
│   │   └── GameOverScreen.gd       # Pantalla de game over
│   │
│   ├── data/                       # Datos y configuración
│   │   ├── GameData.gd             # Datos globales del juego
│   │   ├── TowerData.gd            # Datos de torres
│   │   ├── EnemyData.gd            # Datos de enemigos
│   │   ├── LevelData.gd            # Datos de niveles
│   │   └── WaveData.gd             # Datos de oleadas
│   │
│   ├── api/                        # Conexión con EcoPuntos API
│   │   ├── EcoPuntosAPI.gd         # Cliente principal de la API
│   │   ├── AuthManager.gd          # Manager de autenticación
│   │   ├── PointsManager.gd        # Manager de puntos
│   │   └── HTTPManager.gd          # Manager de HTTP
│   │
│   └── utils/                      # Utilidades
│       ├── Constants.gd            # Constantes del juego
│       ├── Enums.gd               # Enumeraciones
│       ├── MathUtils.gd           # Utilidades matemáticas
│       └── DebugUtils.gd          # Utilidades de debug
│
├── 🎨 assets/                      # Recursos del juego
│   ├── sprites/                    # Sprites e imágenes
│   │   ├── towers/                 # Sprites de torres
│   │   ├── enemies/                # Sprites de enemigos
│   │   ├── projectiles/            # Sprites de proyectiles
│   │   ├── ui/                     # Elementos de UI
│   │   ├── effects/                # Efectos visuales
│   │   └── environment/            # Elementos del entorno
│   │
│   ├── audio/                      # Archivos de audio
│   │   ├── sfx/                    # Efectos de sonido
│   │   ├── music/                  # Música de fondo
│   │   └── voice/                  # Voces y locución
│   │
│   ├── fonts/                      # Fuentes del juego
│   │
│   └── themes/                     # Temas de UI
│       ├── eco_theme.tres          # Tema principal eco
│       └── button_styles.tres      # Estilos de botones
│
├── 🌍 localization/                # Localización
│   ├── en.po                       # Inglés
│   ├── es.po                       # Español
│   └── translations.csv            # CSV de traducciones
│
├── 📊 data/                        # Datos del juego
│   ├── levels/                     # Configuración de niveles
│   │   ├── level_01.json          # Nivel 1 - Básico
│   │   ├── level_02.json          # Nivel 2 - Intermedio
│   │   └── level_03.json          # Nivel 3 - Avanzado
│   │
│   ├── waves/                      # Configuración de oleadas
│   │   ├── wave_patterns.json     # Patrones de oleadas
│   │   └── enemy_spawns.json      # Spawn de enemigos
│   │
│   └── config/                     # Configuración
│       ├── towers_config.json     # Configuración de torres
│       ├── enemies_config.json    # Configuración de enemigos
│       └── game_config.json       # Configuración general
│
└── 🔧 addons/                      # Plugins de Godot
    └── http_request_advanced/      # Plugin avanzado HTTP
```

## 🎯 Características Principales

### 🏗️ Arquitectura Modular
- **Managers separados** para cada sistema
- **Herencia clara** entre clases base y especializadas
- **Inyección de dependencias** entre managers
- **Sistema de eventos** para comunicación desacoplada

### 🌐 Conexión EcoPuntos
- **Autenticación JWT** con el backend Django
- **Sincronización de puntos** por tipo de material
- **Sistema offline/online** con cache local
- **Recompensas automáticas** al completar niveles

### 🎮 Gameplay Profesional
- **Sistema de oleadas** configurable por JSON
- **Torres especializadas** por tipo de material
- **Efectos visuales** y partículas
- **Sistema de upgrades** y mejoras
- **Balanceamento dinámico** basado en performance

### 📱 UI/UX Pulido
- **Themes consistentes** con la identidad EcoPuntos
- **Animaciones fluidas** con Tweens
- **Feedback visual** en todas las acciones
- **Responsive design** para múltiples resoluciones