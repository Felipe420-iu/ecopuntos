extends Node2D

# ===================================
# EcoPuntos Tower Defense - Game World SIMPLIFIED
# ===================================

# 🌍 Scene References
@onready var enemy_path: Path2D = $EnemyPath
@onready var enemies_container: Node2D = $Enemies
@onready var towers_container: Node2D = $Towers
@onready var projectiles_container: Node2D = $Projectiles
@onready var money_label: Label = $UI/GameUI/MoneyLabel
@onready var wave_label: Label = $UI/GameUI/WaveLabel

# 🎮 Game State
var current_money: int = 500
var current_wave: int = 1
var max_waves: int = 5
var enemies_spawned: int = 0
var max_enemies: int = 10

# 👾 Enemy Scene
var enemy_scene = preload("res://scenes/gameplay/enemies/PlasticWaste.tscn")

func _ready():
	print("🌍 GameWorld SIMPLIFIED initialized")
	_update_ui()
	
	# Test spawn after 2 seconds
	get_tree().create_timer(2.0).timeout.connect(_spawn_test_enemy)

func _spawn_test_enemy():
	"""Spawn a test enemy to verify everything works"""
	if enemies_spawned >= max_enemies:
		print("✅ Maximum enemies reached")
		return
	
	var enemy = enemy_scene.instantiate()
	if enemy_path and enemy_path.curve and enemy_path.curve.point_count > 0:
		enemy.global_position = enemy_path.curve.get_point_position(0)
	else:
		enemy.global_position = Vector2(100, 100)
	
	enemy.setup_path(enemy_path)
	enemy.enemy_died.connect(_on_enemy_died)
	enemy.enemy_reached_end.connect(_on_enemy_reached_end)
	
	enemies_container.add_child(enemy)
	enemies_spawned += 1
	
	print("👾 Enemy spawned (", enemies_spawned, "/", max_enemies, ")")
	
	# Spawn next enemy in 2 seconds if not at max
	if enemies_spawned < max_enemies:
		get_tree().create_timer(2.0).timeout.connect(_spawn_test_enemy)

func _on_enemy_died(enemy_type, money_reward: int, score_reward: int):
	"""Handle enemy death"""
	current_money += money_reward
	_update_ui()
	print("💰 Enemy killed! Money: +", money_reward, " Total: $", current_money)

func _on_enemy_reached_end(enemy):
	"""Handle enemy reaching end"""
	print("💔 Enemy reached end!")

func _update_ui():
	"""Update UI labels"""
	if money_label:
		money_label.text = "Dinero: $" + str(current_money)
	if wave_label:
		wave_label.text = "Enemies: " + str(enemies_spawned) + "/" + str(max_enemies)

func _input(event):
	"""Handle input"""
	if event.is_action_pressed("ui_accept"):  # ENTER/SPACE
		_spawn_test_enemy()
		print("🎯 Manual enemy spawn!")
	
	if event.is_action_pressed("ui_cancel"):  # ESC
		get_tree().change_scene_to_file("res://Main.tscn")
	
	# Right click to place tower
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_place_tower_at_mouse()

func _place_tower_at_mouse():
	"""Place tower at mouse position"""
	if current_money >= 100:
		var tower_scene = preload("res://scenes/gameplay/BasicTower.tscn")
		var tower = tower_scene.instantiate()
		tower.global_position = get_global_mouse_position()
		towers_container.add_child(tower)
		current_money -= 100
		_update_ui()
		print("🏗️ Tower placed! Money: -100, Remaining: $", current_money)
	else:
		print("💸 Not enough money! Need $100, have $", current_money)