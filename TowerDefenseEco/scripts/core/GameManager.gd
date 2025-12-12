extends Node

# ===================================
# EcoPuntos Tower Defense - Game Manager
# ===================================

signal game_state_changed(new_state: Constants.GameState)
signal money_changed(new_amount: int)
signal lives_changed(new_amount: int)
signal score_changed(new_score: int)
signal level_started(level_number: int, level_data: Dictionary)
signal level_completed(level_number: int, eco_points_earned: int)
signal game_over_triggered(final_score: int)

# 🎮 Game State
var current_state: Constants.GameState = Constants.GameState.MENU
var current_level: int = 1
var current_wave: int = 1
var total_waves: int = 10

# 💰 Economy
var money: int = Constants.STARTING_MONEY
var lives: int = Constants.STARTING_LIVES
var score: int = 0

# 🏆 Progress
var eco_points_earned: int = 0
var enemies_defeated: int = 0
var towers_built: int = 0

# 📊 Statistics
var statistics = {
	"plastic_recycled": 0,
	"glass_recycled": 0,
	"paper_recycled": 0,
	"metal_recycled": 0,
	"total_recycled": 0,
	"accuracy": 100.0,
	"time_played": 0.0
}

# 🔗 References to Managers
var level_manager: LevelManager
var wave_manager: WaveManager
var tower_manager: TowerManager
var enemy_manager: EnemyManager
var ui_manager: UIManager
var audio_manager: AudioManager
var eco_points_api: EcoPuntosAPI

# ⏱️ Time Management
var start_time: float
var pause_start_time: float
var total_pause_time: float = 0.0

func _ready():
	# Initialize all managers
	_setup_managers()
	_setup_connections()
	
	# Set initial state
	change_game_state(Constants.GameState.MENU)
	
	print("🎮 GameManager initialized successfully")

	# Make this node discoverable via groups
	add_to_group("game_manager")

func _setup_managers():
	"""Initialize all manager nodes"""
	# Find or create manager nodes
	level_manager = get_node_or_create("LevelManager", LevelManager)
	if level_manager: level_manager.add_to_group("level_manager")
	wave_manager = get_node_or_create("WaveManager", WaveManager)
	if wave_manager: wave_manager.add_to_group("wave_manager")
	tower_manager = get_node_or_create("TowerManager", TowerManager)
	if tower_manager: tower_manager.add_to_group("tower_manager")
	enemy_manager = get_node_or_create("EnemyManager", EnemyManager)
	if enemy_manager: enemy_manager.add_to_group("enemy_manager")
	ui_manager = get_node_or_create("UIManager", UIManager)
	if ui_manager: ui_manager.add_to_group("ui_manager")
	audio_manager = get_node_or_create("AudioManager", AudioManager)
	if audio_manager: audio_manager.add_to_group("audio_manager")
	eco_points_api = get_node_or_create("EcoPuntosAPI", EcoPuntosAPI)
	if eco_points_api: eco_points_api.add_to_group("api_manager")

func get_node_or_create(node_name: String, node_class):
	"""Get existing node or create new one"""
	var existing_node = get_node_or_null(node_name)
	if existing_node:
		return existing_node
	
	var new_node = node_class.new()
	new_node.name = node_name
	add_child(new_node)
	return new_node

func _setup_connections():
	"""Setup signal connections between managers"""
	# Enemy Manager connections
	if enemy_manager:
		enemy_manager.enemy_defeated.connect(_on_enemy_defeated)
		enemy_manager.enemy_reached_end.connect(_on_enemy_reached_end)
		enemy_manager.all_enemies_defeated.connect(_on_all_enemies_defeated)
	
	# Wave Manager connections  
	if wave_manager:
		wave_manager.wave_completed.connect(_on_wave_completed)
		wave_manager.all_waves_completed.connect(_on_all_waves_completed)
	
	# Tower Manager connections
	if tower_manager:
		tower_manager.tower_built.connect(_on_tower_built)

func change_game_state(new_state: Constants.GameState):
	"""Change current game state"""
	var old_state = current_state
	current_state = new_state
	
	# Handle state transitions
	match new_state:
		Constants.GameState.PLAYING:
			_start_game()
		Constants.GameState.PAUSED:
			_pause_game()
		Constants.GameState.GAME_OVER:
			_game_over()
		Constants.GameState.VICTORY:
			_victory()
		Constants.GameState.MENU:
			_return_to_menu()
	
	game_state_changed.emit(new_state)
	print("🔄 Game state changed: ", old_state, " → ", new_state)

func _start_game():
	"""Start the game"""
	start_time = Time.get_unix_time_from_system()
	
	# Reset game values
	money = Constants.STARTING_MONEY
	lives = Constants.STARTING_LIVES
	score = 0
	eco_points_earned = 0
	enemies_defeated = 0
	towers_built = 0
	
	# Emit initial values
	money_changed.emit(money)
	lives_changed.emit(lives)
	score_changed.emit(score)
	
	# Start level
	if level_manager:
		level_manager.start_level(current_level)
	
	if audio_manager:
		audio_manager.play_background_music("game_music")

func _pause_game():
	"""Pause the game"""
	pause_start_time = Time.get_unix_time_from_system()
	get_tree().paused = true

func _resume_game():
	"""Resume the game"""
	if pause_start_time > 0:
		total_pause_time += Time.get_unix_time_from_system() - pause_start_time
		pause_start_time = 0
	get_tree().paused = false
	change_game_state(Constants.GameState.PLAYING)

func _game_over():
	"""Handle game over"""
	_calculate_final_statistics()
	get_tree().paused = false
	
	if audio_manager:
		audio_manager.play_sfx("game_over")
	
	game_over_triggered.emit(score)

func _victory():
	"""Handle victory"""
	_calculate_final_statistics()
	_calculate_eco_points_reward()
	
	# Send points to EcoPuntos API
	if eco_points_api and eco_points_api.is_authenticated():
		eco_points_api.add_game_points(eco_points_earned, _get_material_type_from_level())
	
	level_completed.emit(current_level, eco_points_earned)
	
	if audio_manager:
		audio_manager.play_sfx("victory")

func _return_to_menu():
	"""Return to main menu"""
	get_tree().paused = false
	current_level = 1
	current_wave = 1

# 💰 Economy Management
func add_money(amount: int):
	"""Add money to player"""
	money += amount
	money_changed.emit(money)

func spend_money(amount: int) -> bool:
	"""Try to spend money"""
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		return true
	return false

func lose_life(amount: int = 1):
	"""Lose lives"""
	lives -= amount
	lives_changed.emit(lives)
	
	if lives <= 0:
		change_game_state(Constants.GameState.GAME_OVER)

func add_score(amount: int):
	"""Add score"""
	score += amount
	score_changed.emit(score)

# 🏆 Progress Tracking
func _calculate_final_statistics():
	"""Calculate final game statistics"""
	var current_time = Time.get_unix_time_from_system()
	statistics["time_played"] = current_time - start_time - total_pause_time
	statistics["total_recycled"] = (
		statistics["plastic_recycled"] + 
		statistics["glass_recycled"] + 
		statistics["paper_recycled"] + 
		statistics["metal_recycled"]
	)

func _calculate_eco_points_reward():
	"""Calculate EcoPuntos reward based on performance"""
	var base_points = current_level * 50
	var performance_bonus = 0
	
	# Bonus for no lives lost
	if lives == Constants.STARTING_LIVES:
		performance_bonus += base_points * 0.5
	
	# Bonus for high score
	if score > 1000:
		performance_bonus += base_points * 0.3
	
	# Bonus for recycling variety
	var material_types_used = 0
	if statistics["plastic_recycled"] > 0: material_types_used += 1
	if statistics["glass_recycled"] > 0: material_types_used += 1
	if statistics["paper_recycled"] > 0: material_types_used += 1
	if statistics["metal_recycled"] > 0: material_types_used += 1
	
	performance_bonus += material_types_used * base_points * 0.1
	
	eco_points_earned = int(base_points + performance_bonus)

func _get_material_type_from_level() -> String:
	"""Get material type based on current level"""
	match current_level % 4:
		1: return "plastic"
		2: return "glass" 
		3: return "paper"
		0: return "metal"
		_: return "plastic"

# 📡 Signal Handlers
func _on_enemy_defeated(enemy_type: Constants.EnemyType, reward_money: int, reward_score: int):
	"""Handle enemy defeated"""
	add_money(reward_money)
	add_score(reward_score)
	enemies_defeated += 1
	
	# Track recycling statistics
	match enemy_type:
		Constants.EnemyType.PLASTIC_WASTE:
			statistics["plastic_recycled"] += 1
		Constants.EnemyType.GLASS_WASTE:
			statistics["glass_recycled"] += 1
		Constants.EnemyType.PAPER_WASTE:
			statistics["paper_recycled"] += 1
		Constants.EnemyType.METAL_WASTE:
			statistics["metal_recycled"] += 1

func _on_enemy_reached_end():
	"""Handle enemy reaching the end"""
	lose_life()
	
	if audio_manager:
		audio_manager.play_sfx("life_lost")

func _on_all_enemies_defeated():
	"""Handle all enemies in wave defeated"""
	if wave_manager:
		wave_manager.advance_wave()

func _on_wave_completed(wave_number: int):
	"""Handle wave completion"""
	current_wave = wave_number + 1
	
	# Bonus money for completing wave
	var bonus = wave_number * 25
	add_money(bonus)
	
	if audio_manager:
		audio_manager.play_sfx("wave_complete")

func _on_all_waves_completed():
	"""Handle all waves completed (level victory)"""
	change_game_state(Constants.GameState.VICTORY)

func _on_tower_built(tower_type: Constants.TowerType, _cost: int):
	"""Handle tower built"""
	towers_built += 1

# 🎯 Public API for external access
func is_playing() -> bool:
	return current_state == Constants.GameState.PLAYING

func add_coins(amount: int) -> void:
	"""Alias para compatibilidad: añade monedas"""
	add_money(amount)

func add_eco_points(amount: int) -> void:
	"""Añade puntos Eco al total del jugador"""
	eco_points_earned += amount

func can_afford(cost: int) -> bool:
	return money >= cost

func add_screen_shake(duration: float, intensity: float) -> void:
	"""Placeholder: screen shake API for towers to call. UI can connect to this if needed."""
	# TODO: Implement camera/shake effect; for now do nothing
	return

func get_current_statistics() -> Dictionary:
	return statistics.duplicate()

func get_game_progress() -> Dictionary:
	return {
		"level": current_level,
		"wave": current_wave,
		"total_waves": total_waves,
		"money": money,
		"lives": lives,
		"score": score,
		"eco_points": eco_points_earned
	}

## 💾 Save/Load Functions (for LevelManager)
func save_game_data(key: String, data: Dictionary) -> void:
	"""Save game data (placeholder for now)"""
	print("💾 Saving data for key: ", key)
	# TODO: Implement actual save system

func load_game_data(key: String) -> Dictionary:
	"""Load game data (placeholder for now)"""
	print("📂 Loading data for key: ", key)
	# TODO: Implement actual load system
	return {}

func get_game_state() -> int:
	"""Get current game state"""
	return current_state

func get_coins() -> int:
	"""Get current coins amount"""
	return money
