extends Node
class_name WaveManager

signal wave_started(index: int)
signal wave_completed(index: int)
signal enemy_spawned(enemy: Node)

@export var enemy_scene: PackedScene
@export var spawn_point: Marker2D
@export var target_x: float = 1200.0

var waves := [
	{"count": 8, "enemy_level": 1, "health_mult": 1.0, "speed_mult": 1.0, "spawn_interval": 1.1},
	{"count": 10, "enemy_level": 2, "health_mult": 1.15, "speed_mult": 1.05, "spawn_interval": 1.0},
	{"count": 12, "enemy_level": 2, "health_mult": 1.3, "speed_mult": 1.1, "spawn_interval": 0.9},
	{"count": 14, "enemy_level": 3, "health_mult": 1.45, "speed_mult": 1.15, "spawn_interval": 0.85},
]

var current_wave := -1
var enemies_left_to_spawn := 0
var spawn_timer: Timer

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_spawn_enemy)
	_start_next_wave()

func _start_next_wave():
	current_wave += 1
	if current_wave >= waves.size():
		return
	var wave = waves[current_wave]
	enemies_left_to_spawn = wave["count"]
	wave_started.emit(current_wave)
	_spawn_enemy()

func _spawn_enemy():
	if enemies_left_to_spawn <= 0:
		wave_completed.emit(current_wave)
		_start_next_wave()
		return
	var wave = waves[current_wave]
	var enemy: Node = enemy_scene.instantiate()
	# Decide which enemy level to spawn this wave.
	# Rotate levels per wave so each wave looks different: 1..3
	var level_count := 3
	var spawn_level := (current_wave % level_count) + 1
	if enemy.has_method("setup"):
		enemy.setup(spawn_level, wave["health_mult"], wave["speed_mult"])
	enemy.global_position = spawn_point.global_position if spawn_point else Vector2.ZERO
	if enemy.has_method("set_target_x"):
		enemy.set_target_x(target_x)
	add_child(enemy)
	enemy_spawned.emit(enemy)
	enemies_left_to_spawn -= 1
	spawn_timer.start(wave["spawn_interval"])
