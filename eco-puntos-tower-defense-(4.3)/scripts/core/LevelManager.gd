extends Node
class_name LevelManager
# ===================================
# EcoPuntos Tower Defense - Level Manager
# ===================================

## 🎯 Signals
signal level_started(level_data: Dictionary)
signal level_completed(level_number: int, stars: int)
signal level_failed(level_number: int)
signal boss_spawned(boss_data: Dictionary)

## 📊 Level State
var current_level: int = 1
var max_level_unlocked: int = 1
var level_data: Dictionary = {}
var is_level_active: bool = false
var level_start_time: float = 0.0

## 🏆 Level Progress
var levels_completed: Array[int] = []
var level_stars: Dictionary = {} # level_number -> stars_earned
var total_stars: int = 0

## 🎮 Level Configuration - EXPANDIDO
var level_definitions: Dictionary = {
	1: {
		"name": "Playa Contaminada",
		"description": "Limpia la playa de residuos plásticos",
		"waves": 5,
		"difficulty": "easy",
		"eco_theme": "plastic",
		"environment": "beach",
		"boss_wave": 5,
		"rewards": {
			"coins": 100,
			"eco_points": 50,
			"unlock_tower": "glass_tower"
		}
	},
	2: {
		"name": "Bosque Reciclable", 
		"description": "Protege el bosque del papel desechado",
		"waves": 7,
		"difficulty": "medium",
		"eco_theme": "paper",
		"environment": "forest",
		"boss_wave": 7,
		"rewards": {
			"coins": 150,
			"eco_points": 75,
			"unlock_tower": "metal_tower"
		}
	},
	3: {
		"name": "Ciudad Sostenible",
		"description": "Defiende la ciudad de todos los residuos",
		"waves": 10,
		"difficulty": "hard",
		"eco_theme": "mixed",
		"environment": "city",
		"boss_wave": 10,
		"rewards": {
			"coins": 200,
			"eco_points": 100,
			"unlock_achievement": "eco_guardian"
		}
	},
	# NUEVOS NIVELES DESDE CÓDIGO
	4: {
		"name": "Fábrica Abandonada",
		"description": "Limpia los desechos industriales",
		"waves": 12,
		"difficulty": "hard",
		"eco_theme": "metal",
		"environment": "industrial",
		"boss_wave": 12,
		"special_mechanics": ["conveyor_belts", "toxic_waste"],
		"rewards": {
			"coins": 300,
			"eco_points": 150,
			"unlock_tower": "super_recycler"
		}
	},
	5: {
		"name": "Océano Profundo",
		"description": "Salva la vida marina del plástico",
		"waves": 15,
		"difficulty": "extreme",
		"eco_theme": "ocean_plastic",
		"environment": "underwater",
		"boss_wave": 15,
		"special_mechanics": ["underwater_current", "marine_life"],
		"rewards": {
			"coins": 500,
			"eco_points": 250,
			"unlock_achievement": "ocean_savior"
		}
	},
	6: {
		"name": "Estación Espacial Verde",
		"description": "Recicla en gravedad cero",
		"waves": 20,
		"difficulty": "nightmare",
		"eco_theme": "space_debris",
		"environment": "space",
		"boss_wave": 20,
		"special_mechanics": ["zero_gravity", "solar_storms"],
		"rewards": {
			"coins": 1000,
			"eco_points": 500,
			"unlock_achievement": "cosmic_recycler"
		}
	}
}

func _ready():
	print("🎯 LevelManager initialized successfully")
	load_level_progress()

## 🚀 Level Control
func start_level(level_number: int) -> bool:
	if not is_level_available(level_number):
		print("❌ Level ", level_number, " is not available")
		return false
	
	current_level = level_number
	level_data = level_definitions.get(level_number, {})
	is_level_active = true
	# Use unix timestamp for level start time to measure durations reliably
	level_start_time = Time.get_unix_time_from_system()
	
	print("🎮 Starting level ", level_number, ": ", level_data.get("name", "Unknown"))
	
	# Notify GameManager
	if GameManager:
		# Notify GameManager and start wave sequence if available
		GameManager.level_started.emit(level_number, level_data)
		if GameManager.wave_manager:
			GameManager.wave_manager.start_waves()
	
	level_started.emit(level_data)
	return true

func complete_level(stars_earned: int = 3) -> void:
	if not is_level_active:
		return
	
	# Update progress
	if current_level not in levels_completed:
		levels_completed.append(current_level)
	
	# Update stars (keep highest score)
	var previous_stars = level_stars.get(current_level, 0)
	level_stars[current_level] = max(previous_stars, stars_earned)
	
	# Unlock next level
	if current_level + 1 <= level_definitions.size():
		max_level_unlocked = max(max_level_unlocked, current_level + 1)
	
	# Calculate total stars
	total_stars = 0
	for stars in level_stars.values():
		total_stars += stars
	
	# Give rewards
	var rewards = level_data.get("rewards", {})
	if GameManager:
		GameManager.add_coins(rewards.get("coins", 0))
		GameManager.add_eco_points(rewards.get("eco_points", 0))
	
	print("🏆 Level ", current_level, " completed with ", stars_earned, " stars!")
	
	level_completed.emit(current_level, stars_earned)
	is_level_active = false
	
	save_level_progress()

func fail_level() -> void:
	if not is_level_active:
		return
	
	print("💀 Level ", current_level, " failed")
	level_failed.emit(current_level)
	is_level_active = false

## 🔍 Level Queries
func is_level_available(level_number: int) -> bool:
	return level_number <= max_level_unlocked and level_number in level_definitions

func get_level_info(level_number: int) -> Dictionary:
	return level_definitions.get(level_number, {})

func get_current_level_info() -> Dictionary:
	return level_data

func get_level_stars(level_number: int) -> int:
	return level_stars.get(level_number, 0)

func is_level_completed(level_number: int) -> bool:
	return level_number in levels_completed

func get_completion_percentage() -> float:
	if level_definitions.is_empty():
		return 0.0
	return float(levels_completed.size()) / float(level_definitions.size()) * 100.0

## 💾 Save/Load
func save_level_progress() -> void:
	var save_data = {
		"max_level_unlocked": max_level_unlocked,
		"levels_completed": levels_completed,
		"level_stars": level_stars,
		"total_stars": total_stars
	}
	
	# TODO: Save to file or GameManager
	if GameManager:
		GameManager.save_game_data("level_progress", save_data)

func load_level_progress() -> void:
	# TODO: Load from file or GameManager
	if GameManager:
		var save_data = GameManager.load_game_data("level_progress")
		if save_data:
			max_level_unlocked = save_data.get("max_level_unlocked", 1)
			levels_completed = save_data.get("levels_completed", [])
			level_stars = save_data.get("level_stars", {})
			total_stars = save_data.get("total_stars", 0)

## 🎨 Level Themes
func get_level_theme(level_number: int) -> String:
	var info = get_level_info(level_number)
	return info.get("eco_theme", "mixed")

func get_level_difficulty(level_number: int) -> String:
	var info = get_level_info(level_number)
	return info.get("difficulty", "medium")

## 📈 Statistics
func get_total_levels() -> int:
	return level_definitions.size()

func get_completed_levels() -> int:
	return levels_completed.size()

func get_average_stars() -> float:
	if levels_completed.is_empty():
		return 0.0
	return float(total_stars) / float(levels_completed.size())
