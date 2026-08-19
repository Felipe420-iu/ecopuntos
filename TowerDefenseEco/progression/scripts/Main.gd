extends Node2D
class_name MainProgression

const TOWER_BUILD_COST := 100
const TOWER_HIT_PENALTY := 10

@export var tower_scene: PackedScene
@export var wave_manager: Node
@export var initial_money: int = 300

var money: int = 0
var _castle_base_position: Vector2 = Vector2.ZERO
var _castle_base_scale: Vector2 = Vector2.ONE

@onready var castle: Sprite2D = $Castle if has_node("Castle") else null

func _ready() -> void:
	add_to_group("game_state")
	add_to_group("main_root")
	money = initial_money
	if castle:
		_castle_base_position = castle.position
		_castle_base_scale = castle.scale
	_connect_wave_signals()

func _process(_delta: float) -> void:
	if not castle:
		return
	var pulse := sin(Time.get_ticks_msec() * 0.0012)
	castle.position = _castle_base_position + Vector2(0.0, pulse * 2.0)
	castle.scale = _castle_base_scale * Vector2(1.0 + pulse * 0.015, 1.0 - pulse * 0.01)

func _connect_wave_signals() -> void:
	if not wave_manager:
		return
	if not wave_manager is WaveManager:
		return
	wave_manager.wave_started.connect(func(idx: int): print("Wave started", idx))
	wave_manager.enemy_spawned.connect(_on_enemy_spawned)
	wave_manager.wave_completed.connect(func(idx: int): print("Wave completed", idx))

func _on_enemy_spawned(enemy: Node) -> void:
	if not is_instance_valid(enemy):
		return
	if enemy.has_signal("enemy_died"):
		enemy.enemy_died.connect(_on_enemy_died)
	if enemy.has_signal("enemy_reached_end"):
		enemy.enemy_reached_end.connect(_on_enemy_reached_end)

func _on_enemy_died(reward: int) -> void:
	money += max(0, reward)
	print("Money:", money)

func _on_enemy_reached_end() -> void:
	money = max(0, money - TOWER_HIT_PENALTY)
	print("Base hit! Money:", money)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if not event.pressed:
		return
	var mouse_position := get_global_mouse_position()
	if event.button_index == MOUSE_BUTTON_LEFT:
		_place_tower(mouse_position)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		_upgrade_nearest_tower(mouse_position)

func _place_tower(pos: Vector2) -> void:
	if tower_scene == null:
		printerr("MainProgression: tower_scene is null")
		return
	if not try_spend(TOWER_BUILD_COST):
		print("Not enough money to place tower")
		return
	var tower: Node2D = tower_scene.instantiate()
	tower.global_position = pos
	add_child(tower)

func _upgrade_nearest_tower(pos: Vector2) -> void:
	var towers: Array[Node] = get_tree().get_nodes_in_group("towers")
	if towers.is_empty():
		return
	var sorted_towers = towers.duplicate()
	sorted_towers.sort_custom(func(a: Node, b: Node):
		var a_dist := a.global_position.distance_to(pos)
		var b_dist := b.global_position.distance_to(pos)
		return a_dist < b_dist
	)
	var tower: Node = sorted_towers[0]
	if tower is not Tower:
		return
	if tower.upgrade_tower():
		print("Tower upgraded to level", tower.current_level)
	else:
		print("Cannot upgrade (max level or no money)")

func try_spend(amount: int) -> bool:
	if money < amount:
		return false
	money -= amount
	return true
