extends Node
class_name WaveManager

# ===================================
# EcoPuntos Tower Defense - Wave Manager
# ===================================

signal wave_started(wave_number: int, wave_data: Dictionary)
signal wave_completed(wave_number: int)
signal enemy_spawned(enemy: BaseEnemy)
signal all_waves_completed()
signal boss_spawned(boss_instance: Node)

# 🌊 Wave Configuration
@export var waves_data: Array[WaveData] = []
var current_wave: int = 0
var total_waves: int = 10
var enemies_in_current_wave: int = 0
var enemies_spawned_in_wave: int = 0

# ⏰ Spawn Timing
var spawn_timer: Timer
var time_between_spawns: float = 1.0
var time_between_waves: float = 5.0

# 📊 Wave State
var is_wave_active: bool = false
var wave_preparation_time: float = 3.0
var enemies_to_spawn: Array[Dictionary] = []
var current_spawn_index: int = 0

# 🏭 Enemy Factories
var enemy_scenes: Dictionary = {
	Constants.EnemyType.PLASTIC_WASTE: preload("res://scenes/gameplay/enemies/PlasticWaste.tscn"),
	Constants.EnemyType.GLASS_WASTE: preload("res://scenes/gameplay/enemies/GlassWaste.tscn"),
	Constants.EnemyType.PAPER_WASTE: preload("res://scenes/gameplay/enemies/PaperWaste.tscn"),
	Constants.EnemyType.METAL_WASTE: preload("res://scenes/gameplay/enemies/MetalWaste.tscn"),
	Constants.EnemyType.BOSS_WASTE: preload("res://scenes/gameplay/enemies/BossWaste.tscn")
}

# 🎯 References
var enemy_spawn_path: Path2D
var game_manager: GameManager

func _ready():
	# Setup spawn timer
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_spawn_next_enemy)
	add_child(spawn_timer)
	
	# Find references
	_find_references()
	
	# Generate default waves if none provided
	if waves_data.is_empty():
		_generate_default_waves()
	
	print("🌊 WaveManager initialized with ", waves_data.size(), " waves")

func _find_references():
	"""Find required node references"""
	var level_node = get_tree().get_first_node_in_group("level")
	if level_node:
		enemy_spawn_path = level_node.get_node_or_null("EnemyPath")
	
	game_manager = get_tree().get_first_node_in_group("game_manager")

func start_waves():
	"""Start the wave sequence"""
	current_wave = 0
	_start_next_wave()

func _start_next_wave():
	"""Start the next wave"""
	if current_wave >= waves_data.size():
		_complete_all_waves()
		return
	
	is_wave_active = true
	enemies_spawned_in_wave = 0
	current_spawn_index = 0
	
	# Get wave data
	var wave_data = waves_data[current_wave]
	enemies_to_spawn = wave_data.get_spawn_sequence()
	enemies_in_current_wave = enemies_to_spawn.size()
	
	# Emit wave started signal
	wave_started.emit(current_wave + 1)
	
	print("🌊 Wave ", current_wave + 1, " started with ", enemies_in_current_wave, " enemies")
	
	# Start spawning enemies
	if enemies_to_spawn.size() > 0:
		_schedule_next_spawn()

func _schedule_next_spawn():
	"""Schedule the next enemy spawn"""
	if current_spawn_index >= enemies_to_spawn.size():
		return
	
	var spawn_data = enemies_to_spawn[current_spawn_index]
	var delay = spawn_data.get("delay", time_between_spawns)
	
	spawn_timer.wait_time = delay
	spawn_timer.start()

func _spawn_next_enemy():
	"""Spawn the next enemy in the queue"""
	if current_spawn_index >= enemies_to_spawn.size():
		return
	
	var spawn_data = enemies_to_spawn[current_spawn_index]
	_spawn_enemy(spawn_data)
	
	current_spawn_index += 1
	enemies_spawned_in_wave += 1
	
	# Schedule next spawn if there are more enemies
	if current_spawn_index < enemies_to_spawn.size():
		_schedule_next_spawn()

func _spawn_enemy(spawn_data: Dictionary):
	"""Spawn a specific enemy"""
	var enemy_type = spawn_data.get("type", Constants.EnemyType.PLASTIC_WASTE)
	var spawn_position = spawn_data.get("position", Vector2.ZERO)
	
	# Get enemy scene
	var enemy_scene = enemy_scenes.get(enemy_type)
	if not enemy_scene:
		print("⚠️ No scene found for enemy type: ", enemy_type)
		return
	
	# Create enemy instance
	var enemy = enemy_scene.instantiate()
	if not enemy:
		print("⚠️ Failed to instantiate enemy")
		return
	
	# Add to scene
	var level_node = get_tree().get_first_node_in_group("level")
	if level_node:
		level_node.add_child(enemy)
	else:
		get_tree().current_scene.add_child(enemy)
	
	# Position enemy at spawn point
	if enemy_spawn_path and enemy_spawn_path.curve.point_count > 0:
		enemy.global_position = enemy_spawn_path.curve.get_point_position(0) + enemy_spawn_path.global_position
	else:
		enemy.global_position = spawn_position
	
	# Apply wave difficulty scaling
	_apply_difficulty_scaling(enemy)
	
	# Connect enemy signals
	enemy.enemy_died.connect(_on_enemy_died)
	enemy.enemy_reached_end.connect(_on_enemy_reached_end)
	
	# Emit spawn signal
	enemy_spawned.emit(enemy)
	
	print("👾 Spawned ", enemy.get_enemy_name(), " at wave ", current_wave + 1)

func _apply_difficulty_scaling(enemy: BaseEnemy):
	"""Apply difficulty scaling based on wave number"""
	var wave_multiplier = pow(Constants.WAVE_DIFFICULTY_MULTIPLIER, current_wave)
	
	# Scale health
	enemy.max_health = int(enemy.max_health * pow(Constants.ENEMY_HEALTH_SCALE, current_wave))
	enemy.current_health = enemy.max_health
	
	# Scale speed
	enemy.move_speed *= pow(Constants.ENEMY_SPEED_SCALE, current_wave)
	
	# Scale rewards
	enemy.money_reward = int(enemy.money_reward * wave_multiplier)
	enemy.score_reward = int(enemy.score_reward * wave_multiplier)

func advance_wave():
	"""Advance to the next wave"""
	if is_wave_active:
		_complete_current_wave()

func _complete_current_wave():
	"""Complete the current wave"""
	is_wave_active = false
	
	# Emit wave completed signal
	wave_completed.emit(current_wave + 1)
	
	print("✅ Wave ", current_wave + 1, " completed!")
	
	# Move to next wave
	current_wave += 1
	
	# Wait before starting next wave
	await get_tree().create_timer(time_between_waves).timeout
	
	_start_next_wave()

func _complete_all_waves():
	"""Complete all waves (level victory)"""
	print("🏆 All waves completed!")
	all_waves_completed.emit()

func _on_enemy_died(enemy_type: Constants.EnemyType, money_reward: int, score_reward: int):
	"""Handle enemy death"""
	enemies_in_current_wave -= 1
	
	# Check if wave is complete
	if enemies_in_current_wave <= 0 and enemies_spawned_in_wave >= enemies_to_spawn.size():
		advance_wave()

func _on_enemy_reached_end():
	"""Handle enemy reaching the end"""
	enemies_in_current_wave -= 1
	
	# Check if wave is complete
	if enemies_in_current_wave <= 0 and enemies_spawned_in_wave >= enemies_to_spawn.size():
		advance_wave()

# 📊 Wave Data Management
func _generate_default_waves():
	"""Generate default wave configuration"""
	waves_data.clear()
	
	for wave_num in range(total_waves):
		var wave_data = WaveData.new()
		wave_data.wave_number = wave_num + 1
		wave_data.generate_standard_wave(wave_num)
		waves_data.append(wave_data)
	
	print("📋 Generated ", total_waves, " default waves")

func load_waves_from_file(file_path: String) -> bool:
	"""Load wave configuration from JSON file"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("⚠️ Could not open waves file: ", file_path)
		return false
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		print("⚠️ Invalid JSON in waves file")
		return false
	
	var waves_json = json.data
	waves_data.clear()
	
	for wave_json in waves_json:
		var wave_data = WaveData.new()
		wave_data.load_from_json(wave_json)
		waves_data.append(wave_data)
	
	print("📁 Loaded ", waves_data.size(), " waves from file")
	return true

# 🎮 Public API
func get_current_wave_number() -> int:
	return current_wave + 1

func get_total_waves() -> int:
	return waves_data.size()

func get_wave_progress() -> float:
	if not is_wave_active or enemies_to_spawn.is_empty():
		return 0.0
	
	return float(enemies_spawned_in_wave) / float(enemies_to_spawn.size())

func get_enemies_remaining_in_wave() -> int:
	return enemies_in_current_wave

func is_wave_in_progress() -> bool:
	return is_wave_active

func get_wave_info(wave_index: int) -> Dictionary:
	"""Get information about a specific wave"""
	if wave_index < 0 or wave_index >= waves_data.size():
		return {}
	
	var wave_data = waves_data[wave_index]
	return wave_data.get_wave_info()

func skip_wave_delay():
	"""Skip the delay between waves (for testing/fast play)"""
	if spawn_timer.is_stopped():
		_start_next_wave()

# 🔧 Debug/Testing Functions
func force_next_wave():
	"""Force advance to next wave (debug)"""
	print("🔧 Force advancing to next wave")
	advance_wave()

func spawn_test_enemy(enemy_type: Constants.EnemyType):
	"""Spawn a test enemy (debug)"""
	var spawn_data = {
		"type": enemy_type,
		"position": Vector2.ZERO
	}
	_spawn_enemy(spawn_data)
