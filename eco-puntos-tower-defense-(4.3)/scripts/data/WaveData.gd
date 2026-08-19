extends Resource
class_name WaveData

# ===================================
# EcoPuntos Tower Defense - Wave Data Configuration
# ===================================

@export var wave_number: int = 1
@export var enemy_spawn_data: Array[Dictionary] = []
@export var wave_duration: float = 30.0
@export var preparation_time: float = 3.0

# 🌊 Wave Generation Methods
func generate_standard_wave(wave_index: int):
	"""Generate a standard wave configuration"""
	wave_number = wave_index + 1
	enemy_spawn_data.clear()
	
	# Base enemy counts
	var base_plastic_count = 5 + wave_index
	var base_glass_count = max(0, wave_index - 1)
	var base_paper_count = max(0, wave_index - 2)
	var base_metal_count = max(0, wave_index - 3)
	
	# Add boss every 5 waves
	var has_boss = (wave_index + 1) % 5 == 0
	
	# Generate spawn sequence
	_add_enemy_group(Constants.EnemyType.PLASTIC_WASTE, base_plastic_count, 0.0, 1.0)
	
	if base_glass_count > 0:
		_add_enemy_group(Constants.EnemyType.GLASS_WASTE, base_glass_count, 5.0, 1.5)
	
	if base_paper_count > 0:
		_add_enemy_group(Constants.EnemyType.PAPER_WASTE, base_paper_count, 10.0, 0.8)
	
	if base_metal_count > 0:
		_add_enemy_group(Constants.EnemyType.METAL_WASTE, base_metal_count, 15.0, 2.0)
	
	if has_boss:
		_add_enemy_group(Constants.EnemyType.BOSS_WASTE, 1, 20.0, 5.0)

func _add_enemy_group(enemy_type: Constants.EnemyType, count: int, start_delay: float, spawn_interval: float):
	"""Add a group of enemies to the spawn sequence"""
	for i in range(count):
		var spawn_data = {
			"type": enemy_type,
			"delay": start_delay + (i * spawn_interval),
			"position": Vector2.ZERO
		}
		enemy_spawn_data.append(spawn_data)

func load_from_json(json_data: Dictionary):
	"""Load wave data from JSON"""
	wave_number = json_data.get("wave_number", 1)
	wave_duration = json_data.get("wave_duration", 30.0)
	preparation_time = json_data.get("preparation_time", 3.0)
	
	enemy_spawn_data.clear()
	var enemies_json = json_data.get("enemies", [])
	
	for enemy_json in enemies_json:
		var spawn_data = {
			"type": _parse_enemy_type(enemy_json.get("type", "plastic_waste")),
			"delay": enemy_json.get("delay", 0.0),
			"position": Vector2(enemy_json.get("x", 0), enemy_json.get("y", 0))
		}
		enemy_spawn_data.append(spawn_data)

func _parse_enemy_type(type_string: String) -> Constants.EnemyType:
	"""Parse enemy type from string"""
	match type_string.to_lower():
		"plastic_waste", "plastic":
			return Constants.EnemyType.PLASTIC_WASTE
		"glass_waste", "glass":
			return Constants.EnemyType.GLASS_WASTE
		"paper_waste", "paper":
			return Constants.EnemyType.PAPER_WASTE
		"metal_waste", "metal":
			return Constants.EnemyType.METAL_WASTE
		"boss_waste", "boss":
			return Constants.EnemyType.BOSS_WASTE
		_:
			return Constants.EnemyType.PLASTIC_WASTE

func get_spawn_sequence() -> Array[Dictionary]:
	"""Get the spawn sequence sorted by delay"""
	var sorted_sequence = enemy_spawn_data.duplicate()
	sorted_sequence.sort_custom(func(a, b): return a.delay < b.delay)
	return sorted_sequence

func get_wave_info() -> Dictionary:
	"""Get wave information summary"""
	var enemy_counts = {}
	var total_enemies = 0
	
	for spawn_data in enemy_spawn_data:
		var type = spawn_data["type"]
		enemy_counts[type] = enemy_counts.get(type, 0) + 1
		total_enemies += 1
	
	return {
		"wave_number": wave_number,
		"total_enemies": total_enemies,
		"enemy_counts": enemy_counts,
		"duration": wave_duration,
		"prep_time": preparation_time
	}

func get_total_enemy_count() -> int:
	"""Get total number of enemies in this wave"""
	return enemy_spawn_data.size()

func get_wave_difficulty() -> float:
	"""Calculate wave difficulty based on enemy composition"""
	var difficulty = 0.0
	var weights = {
		Constants.EnemyType.PLASTIC_WASTE: 1.0,
		Constants.EnemyType.GLASS_WASTE: 1.5,
		Constants.EnemyType.PAPER_WASTE: 1.2,
		Constants.EnemyType.METAL_WASTE: 2.0,
		Constants.EnemyType.BOSS_WASTE: 5.0
	}
	
	for spawn_data in enemy_spawn_data:
		var enemy_type = spawn_data["type"]
		difficulty += weights.get(enemy_type, 1.0)
	
	return difficulty