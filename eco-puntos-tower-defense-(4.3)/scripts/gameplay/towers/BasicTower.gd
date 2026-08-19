extends CharacterBody2D
class_name BasicTower

# ===================================
# EcoPuntos Tower Defense - Basic Tower
# ===================================

signal projectile_fired(projectile)

## 🏗️ Tower Properties
@export var tower_type: Constants.TowerType = Constants.TowerType.PLASTIC
@export var fire_rate: float = 1.0  # Shots per second
@export var damage: float = 25.0
@export var range: float = 120.0
@export var projectile_speed: float = 300.0

## 🎯 Targeting
var target_enemy: CharacterBody2D = null
var enemies_in_range: Array[CharacterBody2D] = []
var fire_timer: Timer

## 🎨 Visual Components
@onready var range_indicator: Node2D = $RangeIndicator if has_node("RangeIndicator") else null
@onready var cannon: Node2D = $Cannon if has_node("Cannon") else null
@onready var visual: Node2D = $Visual if has_node("Visual") else null

func _ready():
	print("🏗️ Basic Tower placed")
	
	# Setup fire timer
	_setup_fire_timer()
	
	# Setup detection area
	_setup_detection_area()
	
	# Setup visuals
	_setup_visuals()

func _setup_fire_timer():
	"""Setup automatic firing timer"""
	fire_timer = Timer.new()
	fire_timer.wait_time = 1.0 / fire_rate
	fire_timer.timeout.connect(_try_fire)
	add_child(fire_timer)
	fire_timer.start()

func _setup_detection_area():
	"""Setup area to detect enemies"""
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = range
	collision.shape = circle_shape
	area.add_child(collision)
	add_child(area)
	
	# Connect area signals
	area.body_entered.connect(_on_enemy_entered_range)
	area.body_exited.connect(_on_enemy_exited_range)

func _setup_visuals():
	"""Setup tower visual appearance"""
	# This will be handled by the Visual node if it exists
	pass

func _try_fire():
	"""Try to fire at target enemy"""
	_update_target()
	
	if target_enemy and is_instance_valid(target_enemy):
		_fire_at_target()

func _update_target():
	"""Update current target enemy"""
	# Remove invalid enemies from list
	enemies_in_range = enemies_in_range.filter(func(enemy): return is_instance_valid(enemy))
	
	if enemies_in_range.is_empty():
		target_enemy = null
		return
	
	# Target closest enemy to end of path
	# For simplicity, target first enemy in range
	target_enemy = enemies_in_range[0]

func _fire_at_target():
	"""Fire projectile at current target"""
	if not target_enemy:
		return
	
	print("💥 Tower firing at enemy!")
	
	# Calculate direction to target
	var direction = (target_enemy.global_position - global_position).normalized()
	
	# Rotate cannon if it exists
	if cannon:
		cannon.rotation = direction.angle()
	
	# Create simple projectile
	_create_projectile(direction)

func _create_projectile(direction: Vector2):
	"""Create and fire projectile"""
	var projectile = preload("res://scenes/gameplay/BasicProjectile.tscn").instantiate()
	
	# Setup projectile
	projectile.global_position = global_position
	projectile.direction = direction
	projectile.speed = projectile_speed
	projectile.damage = damage
	projectile.target_enemy = target_enemy
	
	# Add to projectiles container
	var game_world = get_tree().get_first_node_in_group("game_world")
	if game_world:
		var projectiles_container = game_world.get_node("Projectiles")
		projectiles_container.add_child(projectile)
		projectile_fired.emit(projectile)

func _on_enemy_entered_range(body):
	"""Handle enemy entering range"""
	if body.has_method("take_damage"):  # Check if it's an enemy
		enemies_in_range.append(body)
		print("🎯 Enemy entered tower range")

func _on_enemy_exited_range(body):
	"""Handle enemy exiting range"""
	if body in enemies_in_range:
		enemies_in_range.erase(body)
		if target_enemy == body:
			target_enemy = null
		print("📤 Enemy exited tower range")

func _draw():
	"""Debug drawing for range indicator"""
	if get_viewport().debug_collisions_hint:
		draw_circle(Vector2.ZERO, range, Color(0, 1, 0, 0.1))
		draw_arc(Vector2.ZERO, range, 0, TAU, 64, Color(0, 1, 0, 0.5), 2.0)