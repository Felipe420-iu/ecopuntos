extends Node2D

# ===================================
# EcoPuntos Tower Defense - Game World SIMPLIFIED
# ===================================

# 🌍 Scene References
@onready var enemy_path: Path2D = get_node_or_null("EnemyPath")
@onready var enemies_container: Node2D = $Enemies
@onready var towers_container: Node2D = $Towers
@onready var projectiles_container: Node2D = $Projectiles
@onready var map: Node2D = $Map
@onready var money_label: Label = $UI/GameUI/TopBar/TopHBox/MoneyLabel
@onready var wave_label: Label = $UI/GameUI/TopBar/TopHBox/WaveLabel
@onready var lives_label: Label = $UI/GameUI/TopBar/TopHBox/LivesLabel
@onready var status_label: Label = $UI/GameUI/BottomBar/StatusLabel
@onready var camera: Camera2D = $Camera2D
@onready var castle: Sprite2D = $Castle if has_node("Castle") else null

# 🎮 Game State
var current_money: int = 500
var current_wave: int = 1
var max_waves: int = 5
var enemies_spawned: int = 0
var enemies_alive: int = 0
var enemies_per_wave: int = 20
var spawn_interval: float = 1.5
var time_between_waves: float = 3.0
var wave_in_progress: bool = false
var lives: int = 10
var castle_max_health: int = 10
var tower_cost: int = 100
var tower_upgrade_costs := [80, 120, 180]

const WAVE_HEALTH_MULTS := [0.8, 1.0, 1.25, 1.55, 1.9]
const WAVE_SPEED_MULTS := [0.95, 1.0, 1.05, 1.1, 1.16]
const WAVE_REWARD_MULTS := [1.0, 1.08, 1.15, 1.22, 1.3]
const WAVE_ENEMY_COUNTS := [12, 14, 16, 18, 20]
const WAVE_SPAWN_INTERVALS := [1.55, 1.4, 1.25, 1.1, 0.95]

# 👾 Enemy Scene
var enemy_scene = preload("res://scenes/gameplay/enemies/PlasticWaste.tscn")
var spawn_timer: Timer

func _ready():
	print("🌍 GameWorld SIMPLIFIED initialized")
	add_to_group("game_world")
	# Reset state
	enemies_spawned = 0
	enemies_alive = 0
	lives = castle_max_health
	# Clear any enemies left from previous runs
	if enemies_container:
		for child in enemies_container.get_children():
			child.queue_free()
	# Timer para spawns escalonados
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_spawn_next_enemy)
	add_child(spawn_timer)
	# Make sure a path exists even if the scene node was missing
	_ensure_enemy_path()
	# Configure path to follow the map layout
	_configure_path_from_map()
	_ensure_straight_path_layout()
	_place_castle_at_exit()
	# Camera smoothing
	if camera:
		camera.zoom = Vector2(0.9, 0.9)
		camera.position = _get_map_center()
		camera.enabled = true
	_update_ui()
	# Arranca la primera oleada automáticamente
	_start_wave(current_wave)

func _start_wave(wave_number: int):
	"""Configura y arranca una oleada de forma automática"""
	if wave_number > max_waves:
		status_label.text = "Todas las oleadas completadas"
		return

	var wave_index: int = int(clamp(wave_number - 1, 0, WAVE_HEALTH_MULTS.size() - 1))
	current_wave = wave_number
	enemies_per_wave = WAVE_ENEMY_COUNTS[wave_index]
	spawn_interval = WAVE_SPAWN_INTERVALS[wave_index]
	enemies_spawned = 0
	enemies_alive = 0
	wave_in_progress = true
	status_label.text = "Oleada %s/%s en progreso" % [current_wave, max_waves]
	_update_ui()
	_spawn_next_enemy()

func _spawn_next_enemy():
	"""Genera el siguiente enemigo de la oleada"""
	if enemies_spawned >= enemies_per_wave:
		return

	var enemy = enemy_scene.instantiate()
	var wave_index: int = int(clamp(current_wave - 1, 0, WAVE_HEALTH_MULTS.size() - 1))
	var start_pos := Vector2(640, 360)
	if enemy_path:
		start_pos = enemy_path.to_global(Vector2.ZERO)
		if enemy_path.curve and enemy_path.curve.point_count > 0:
			start_pos = enemy_path.to_global(enemy_path.curve.get_point_position(0))
		enemy.global_position = start_pos
		if enemy.has_method("set_wave_theme"):
			enemy.set_wave_theme(current_wave)
		if enemy.has_method("set_difficulty"):
			enemy.set_difficulty(WAVE_HEALTH_MULTS[wave_index], WAVE_SPEED_MULTS[wave_index], WAVE_REWARD_MULTS[wave_index])
		enemy.setup_path(enemy_path)
		if enemy.has_method("set_visual_variant"):
			var variant_index: int = (current_wave - 1) % 3
			enemy.set_visual_variant(variant_index)
	else:
		enemy.global_position = start_pos

	enemy.enemy_died.connect(_on_enemy_died)
	enemy.enemy_reached_end.connect(_on_enemy_reached_end)

	enemies_container.add_child(enemy)
	enemies_spawned += 1
	enemies_alive += 1
	_update_ui()

	print("👾 Enemy spawned (", enemies_spawned, "/", enemies_per_wave, ") en oleada ", current_wave)

	if enemies_spawned < enemies_per_wave:
		spawn_timer.start(spawn_interval)

func _on_enemy_died(enemy_type, money_reward: int, score_reward: int):
	"""Handle enemy death"""
	current_money += money_reward
	enemies_alive = max(0, enemies_alive - 1)
	_update_ui()
	print("💰 Enemy killed! Money: +", money_reward, " Total: $", current_money)
	_check_wave_completion()

func _on_enemy_reached_end(damage_to_base: int):
	"""Handle enemy reaching end"""
	print("💔 Enemy reached end!")
	lives = max(0, lives - max(1, damage_to_base))
	enemies_alive = max(0, enemies_alive - 1)
	_update_ui()
	if lives <= 0:
		status_label.text = "El castillo cayó"
		wave_in_progress = false
		if spawn_timer:
			spawn_timer.stop()
	_check_wave_completion()

func _check_wave_completion():
	"""Detecta fin de oleada y lanza la siguiente"""
	if not wave_in_progress:
		return
	var all_spawned := enemies_spawned >= enemies_per_wave
	var none_alive := enemies_alive <= 0
	if all_spawned and none_alive:
		wave_in_progress = false
		status_label.text = "Oleada %s completada" % current_wave
		if current_wave < max_waves:
			await get_tree().create_timer(time_between_waves).timeout
			_start_wave(current_wave + 1)
		else:
			status_label.text = "Todas las oleadas completadas"

func _update_ui():
	"""Update UI labels"""
	if money_label:
		money_label.text = "Dinero: $" + str(current_money)
	if wave_label:
		wave_label.text = "Oleada " + str(current_wave) + "/" + str(max_waves) + " | Enemigos " + str(enemies_spawned) + "/" + str(enemies_per_wave)
	if lives_label:
		lives_label.text = "🏰 " + str(lives) + "/" + str(castle_max_health)
	if status_label:
		var status_text = status_label.text
		if wave_in_progress:
			status_text = "Oleada %s/%s en progreso" % [current_wave, max_waves]
		elif status_text == "":
			status_text = "EcoPuntos Tower Defense - En progreso"
		status_label.text = status_text

func _input(event):
	"""Handle input"""
	if event.is_action_pressed("ui_cancel"):  # ESC
		get_tree().change_scene_to_file("res://Main.tscn")

	# Click derecho: colocar torre
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_place_tower_at_mouse()

	# Click izquierdo: mejorar torre cercana
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_upgrade_nearest_tower(get_global_mouse_position())
	
	# Right click to place tower
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_place_tower_at_mouse()

func _place_tower_at_mouse():
	"""Place tower at mouse position"""
	if current_money >= tower_cost:
		var tower_scene = preload("res://scenes/gameplay/BasicTower.tscn")
		var tower = tower_scene.instantiate()
		tower.global_position = get_global_mouse_position()
		towers_container.add_child(tower)
		current_money -= tower_cost
		_update_ui()
		print("🏗️ Tower placed! Money: -%s, Remaining: $%s" % [tower_cost, current_money])
	else:
		print("💸 Not enough money! Need $%s, have $%s" % [tower_cost, current_money])

func _upgrade_nearest_tower(pos: Vector2):
	"""Find and upgrade the closest tower if player can afford it"""
	var towers = towers_container.get_children()
	if towers.is_empty():
		return
	towers.sort_custom(func(a, b): return a.global_position.distance_to(pos) < b.global_position.distance_to(pos))
	var tower = towers[0]
	if not tower or not tower.has_method("upgrade"):
		return
	var next_cost = tower.call("get_upgrade_cost") if tower.has_method("get_upgrade_cost") else (tower_upgrade_costs.min() if tower_upgrade_costs else 100)
	if next_cost <= 0:
		print("⏫ Torre ya está al nivel máximo")
		return
	if current_money < next_cost:
		print("💸 Falta dinero para mejorar: cuesta %s, tienes %s" % [next_cost, current_money])
		return
	if tower.upgrade():
		current_money -= next_cost
		_update_ui()
		print("⬆️ Torre mejorada. Nivel actual: ", tower.get("level"))
	else:
		print("⚠️ No se pudo mejorar la torre")

func _configure_path_from_map():
	if enemy_path == null:
		print("⚠️ EnemyPath not found; skipping path configuration")
		return
	if not (map and map.has_method("get_entry_point") and map.has_method("get_exit_point")):
		print("⚠️ Map entry/exit not available, keeping default path")
		return
	var entry: Vector2 = map.call("get_entry_point") as Vector2
	var exit: Vector2 = map.call("get_exit_point") as Vector2
	var mid1: Vector2 = entry.lerp(exit, 0.4) + Vector2(0, -64)
	var mid2: Vector2 = entry.lerp(exit, 0.6) + Vector2(0, -96)
	var curve := Curve2D.new()
	curve.add_point(entry)
	curve.add_point(mid1)
	curve.add_point(mid2)
	curve.add_point(exit)
	enemy_path.curve = curve

func _ensure_straight_path_layout():
	"""Guarantee a simple camino recto para que los enemigos caminen derecho"""
	if enemy_path == null:
		return
	var curve := Curve2D.new()
	var y_path = _get_map_center().y
	var start := Vector2(-200, y_path)
	var finish := Vector2(1480, y_path)
	curve.add_point(start)
	curve.add_point(finish)
	enemy_path.curve = curve

func _place_castle_at_exit() -> void:
	if castle == null:
		var castle_texture := load("res://assets/desert_pack/castle_end.png") as Texture2D
		if castle_texture == null:
			return
		castle = Sprite2D.new()
		castle.name = "Castle"
		castle.texture = castle_texture
		castle.centered = true
		castle.z_index = 20
		add_child(castle)
	var exit_point := _get_map_exit_point()
	castle.position = exit_point + Vector2(40, -20)
	castle.scale = Vector2(1.25, 1.25)
	castle.z_index = 20

func _get_map_center() -> Vector2:
	if map and map.has_method("get_center_point"):
		return map.call("get_center_point")
	return Vector2(640, 360)

func _get_map_exit_point() -> Vector2:
	if map and map.has_method("get_exit_point"):
		return map.call("get_exit_point")
	return Vector2(1200, 360)

func _ensure_enemy_path():
	if enemy_path:
		return
	# Build a minimal path so the scene keeps running even if the node is missing
	enemy_path = Path2D.new()
	enemy_path.name = "EnemyPath"
	var fallback_curve := Curve2D.new()
	fallback_curve.add_point(Vector2.ZERO)
	fallback_curve.add_point(Vector2(1280, 0))
	enemy_path.curve = fallback_curve
	add_child(enemy_path)
	var follower := PathFollow2D.new()
	follower.name = "PathFollow2D"
	enemy_path.add_child(follower)
	var spawn_marker := Marker2D.new()
	spawn_marker.name = "SpawnPoint"
	follower.add_child(spawn_marker)
