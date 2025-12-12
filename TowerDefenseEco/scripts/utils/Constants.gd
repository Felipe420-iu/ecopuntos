# ===================================
# EcoPuntos Tower Defense - Constantes
# ===================================

extends Node

# 🌐 API Configuration
const API_BASE_URL = "http://localhost:8000/api/"  # Cambiar por tu dominio Railway
const API_LOGIN_ENDPOINT = "auth/login/"
const API_PROFILE_ENDPOINT = "usuarios/perfil/"
const API_UPDATE_POINTS_ENDPOINT = "usuarios/actualizar-perfil/"

# 🎮 Game Constants
const GAME_TITLE = "EcoPuntos Tower Defense"
const GAME_VERSION = "1.0.0"

# Backwards-compatible aliases (used by some scenes/scripts)
const BASE_TOWER_COST = 100
const ECOPUNTOS_API_URL = API_BASE_URL

# 🏗️ Tower Types
enum TowerType {
	PLASTIC,
	GLASS,
	PAPER,
	METAL
}

# 👾 Enemy Types  
enum EnemyType {
	PLASTIC_WASTE,
	GLASS_WASTE,
	PAPER_WASTE,
	METAL_WASTE,
	BOSS_WASTE
}

# 💥 Projectile Types
enum ProjectileType {
	RECYCLE_BULLET,
	CLEAN_BEAM,
	ECO_BOMB
}

# 🏆 Game States
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER,
	VICTORY,
	LOADING
}

# 💰 Economy
const STARTING_MONEY = 150
const STARTING_LIVES = 20
const MONEY_PER_KILL = 10
const LIFE_LOSS_PER_ENEMY = 1

# 🎯 Difficulty Settings
const WAVE_DIFFICULTY_MULTIPLIER = 1.15
const ENEMY_HEALTH_SCALE = 1.1
const ENEMY_SPEED_SCALE = 1.05

# 🎨 UI Colors
const COLOR_ECO_GREEN = Color(0.2, 0.8, 0.3, 1.0)
const COLOR_ECO_BLUE = Color(0.1, 0.6, 0.9, 1.0)
const COLOR_ECO_ORANGE = Color(0.9, 0.6, 0.1, 1.0)
const COLOR_DANGER_RED = Color(0.9, 0.2, 0.1, 1.0)

# 🔧 Performance Settings
const MAX_PROJECTILES_ON_SCREEN = 100
const MAX_PARTICLES_PER_EFFECT = 50
const TARGET_FPS = 60

# 📊 Points Configuration
const POINTS_PER_PLASTIC_ENEMY = 15
const POINTS_PER_GLASS_ENEMY = 20
const POINTS_PER_PAPER_ENEMY = 12
const POINTS_PER_METAL_ENEMY = 25
const POINTS_PER_BOSS_ENEMY = 100

# 🎵 Audio Settings
const MASTER_VOLUME_DB = 0.0
const SFX_VOLUME_DB = -5.0
const MUSIC_VOLUME_DB = -15.0
