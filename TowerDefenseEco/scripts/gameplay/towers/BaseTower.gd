extends Node2D
class_name BaseTower

# ===================================
# EcoPuntos Tower Defense - Base Tower
# ===================================

signal tower_built(tower_type: Constants.TowerType, cost: int)
signal enemy_targeted(enemy: BaseEnemy)
signal projectile_fired(projectile: BaseProjectile)

# 🏗️ Tower Properties
@export var tower_type: Constants.TowerType = Constants.TowerType.PLASTIC
@export var tower_name: String = "Base Tower"
@export var build_cost: int = 50
@export var damage: int = 25
@export var fire_rate: float = 1.0  # attacks per second
@export var range_radius: float = 120.0
@export var projectile_speed: float = 300.0

# 🎯 Targeting
@export var target_priority: TargetPriority = TargetPriority.FIRST
@export var can_target_air: bool = true
@export var can_target_ground: bool = true

enum TargetPriority {
	FIRST,      # First enemy in line
	LAST,       # Last enemy in line  
	CLOSEST,    # Closest to tower
	STRONGEST,  # Highest health
	WEAKEST     # Lowest health
}

# 🔫 Combat State
var current_target: BaseEnemy = null
var can_fire: bool = true
var last_fire_time: float = 0.0
var projectile_scene: PackedScene

# 🎨 Visual Components
@onready var sprite: Sprite2D = $Sprite2D
@onready var range_indicator: Sprite2D = $RangeIndicator
@onready var barrel: Sprite2D = $Barrel
@onready var muzzle_flash: CPUParticles2D = $MuzzleFlash
@onready var detection_area: Area2D = $DetectionArea
@onready var detection_collision: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var fire_timer: Timer = $FireTimer
@onready var upgrade_indicator: Sprite2D = $UpgradeIndicator

# 📊 Tower Stats
var level: int = 1
var max_level: int = 3
var upgrade_cost_multiplier: float = 1.5
var enemies_in_range: Array[BaseEnemy] = []
var total_damage_dealt: int = 0
var enemies_killed: int = 0

func _ready():
	# Setup tower
	_setup_tower_visuals()
	_setup_detection_area()
	_setup_fire_timer()
	_setup_projectile()
	
	# Connect signals
	_connect_signals()
	
	print("🗼 ", tower_name, " tower built at ", global_position)

func _setup_tower_visuals():
	"""Setup tower visual appearance"""
	# Hide range indicator initially
	if range_indicator:
		range_indicator.visible = false
		range_indicator.scale = Vector2.ONE * (range_radius / 60.0)  # Assuming 60px base radius
		range_indicator.modulate = Color(1.0, 1.0, 1.0, 0.3)
	
	# Setup upgrade indicator
	if upgrade_indicator:
		upgrade_indicator.visible = false

func _setup_detection_area():
	"""Setup enemy detection area"""
	if detection_area and detection_collision:
		# Create circular collision shape
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = range_radius
		detection_collision.shape = circle_shape

func _setup_fire_timer():
	"""Setup firing timer"""
	if fire_timer:
		fire_timer.wait_time = 1.0 / fire_rate
		fire_timer.one_shot = true
		fire_timer.timeout.connect(_on_fire_timer_timeout)

func _setup_projectile():
	"""Setup projectile scene - override in child classes"""
	# Default projectile
	projectile_scene = preload("res://scenes/gameplay/projectiles/RecycleBullet.tscn")

func _connect_signals():
	"""Connect area signals"""
	if detection_area:
		detection_area.body_entered.connect(_on_enemy_entered_range)
		detection_area.body_exited.connect(_on_enemy_exited_range)

func _process(delta):
	if current_target:
		_track_target()
		_try_fire_at_target()
	else:
		_find_new_target()

func _track_target():
	"""Rotate barrel to track current target"""
	if not current_target or not is_instance_valid(current_target):
		current_target = null
		return
	
	# Check if target is still in range
	var distance_to_target = global_position.distance_to(current_target.global_position)
	if distance_to_target > range_radius:
		current_target = null
		return
	
	# Rotate barrel towards target
	if barrel:
		var direction_to_target = current_target.global_position - global_position
		barrel.rotation = direction_to_target.angle()

func _find_new_target():
	"""Find a new target based on priority"""
	if enemies_in_range.is_empty():
		return
	
	# Remove invalid enemies
	enemies_in_range = enemies_in_range.filter(func(enemy): return is_instance_valid(enemy) and not enemy.is_dying)
	
	if enemies_in_range.is_empty():
		return
	
	# Select target based on priority
	match target_priority:
		TargetPriority.FIRST:
			current_target = _get_first_enemy()
		TargetPriority.LAST:
			current_target = _get_last_enemy()
		TargetPriority.CLOSEST:
			current_target = _get_closest_enemy()
		TargetPriority.STRONGEST:
			current_target = _get_strongest_enemy()
		TargetPriority.WEAKEST:
			current_target = _get_weakest_enemy()
	
	if current_target:
		enemy_targeted.emit(current_target)

func _try_fire_at_target():
	"""Try to fire at current target"""
	if not current_target or not can_fire or not fire_timer.is_stopped():
		return
	
	_fire_projectile()

func _fire_projectile():
	"""Fire a projectile at current target"""
	if not projectile_scene or not current_target:
		return
	
	# Create projectile
	var projectile = projectile_scene.instantiate()
	if not projectile:
		return
	
	# Add to scene
	get_tree().current_scene.add_child(projectile)
	
	# Setup projectile
	projectile.global_position = global_position
	projectile.setup_projectile(current_target, damage, projectile_speed, self)
	
	# Start fire timer
	fire_timer.start()
	
	# Play effects
	_play_fire_effects()
	
	# Emit signal
	projectile_fired.emit(projectile)
	
	print("💥 ", tower_name, " fired at ", current_target.get_enemy_name())

func _play_fire_effects():
	"""Play firing visual and audio effects"""
	# Muzzle flash
	if muzzle_flash:
		muzzle_flash.emitting = true
	
	# Screen shake
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("add_screen_shake"):
		game_manager.add_screen_shake(1.0, 0.1)
	
	# Audio (will be handled by AudioManager)
	var audio_manager = get_tree().get_first_node_in_group("audio_manager")
	if audio_manager and audio_manager.has_method("play_tower_fire_sfx"):
		audio_manager.play_tower_fire_sfx(tower_type)

# 🎯 Target Selection Methods
func _get_first_enemy() -> BaseEnemy:
	"""Get enemy that's furthest along the path"""
	var first_enemy: BaseEnemy = null
	var max_distance = -1.0
	
	for enemy in enemies_in_range:
		if enemy.distance_traveled > max_distance:
			max_distance = enemy.distance_traveled
			first_enemy = enemy
	
	return first_enemy

func _get_last_enemy() -> BaseEnemy:
	"""Get enemy that's least along the path"""
	var last_enemy: BaseEnemy = null
	var min_distance = INF
	
	for enemy in enemies_in_range:
		if enemy.distance_traveled < min_distance:
			min_distance = enemy.distance_traveled
			last_enemy = enemy
	
	return last_enemy

func _get_closest_enemy() -> BaseEnemy:
	"""Get closest enemy to tower"""
	var closest_enemy: BaseEnemy = null
	var min_distance = INF
	
	for enemy in enemies_in_range:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func _get_strongest_enemy() -> BaseEnemy:
	"""Get enemy with highest health"""
	var strongest_enemy: BaseEnemy = null
	var max_health = -1
	
	for enemy in enemies_in_range:
		if enemy.current_health > max_health:
			max_health = enemy.current_health
			strongest_enemy = enemy
	
	return strongest_enemy

func _get_weakest_enemy() -> BaseEnemy:
	"""Get enemy with lowest health"""
	var weakest_enemy: BaseEnemy = null
	var min_health = INF
	
	for enemy in enemies_in_range:
		if enemy.current_health < min_health:
			min_health = enemy.current_health
			weakest_enemy = enemy
	
	return weakest_enemy

# 🔧 Upgrade System
func can_upgrade() -> bool:
	"""Check if tower can be upgraded"""
	return level < max_level

func get_upgrade_cost() -> int:
	"""Get cost to upgrade tower"""
	return int(build_cost * pow(upgrade_cost_multiplier, level))

func upgrade() -> bool:
	"""Upgrade the tower"""
	if not can_upgrade():
		return false
	
	var cost = get_upgrade_cost()
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	
	if game_manager and game_manager.can_afford(cost):
		game_manager.spend_money(cost)
		_apply_upgrade()
		return true
	
	return false

func _apply_upgrade():
	"""Apply upgrade effects"""
	level += 1
	
	# Improve stats
	damage = int(damage * 1.3)
	fire_rate *= 1.2
	range_radius *= 1.1
	
	# Update visuals
	_update_upgrade_visuals()
	
	# Update fire timer
	if fire_timer:
		fire_timer.wait_time = 1.0 / fire_rate
	
	# Update detection area
	if detection_collision:
		var circle_shape = detection_collision.shape as CircleShape2D
		if circle_shape:
			circle_shape.radius = range_radius
	
	# Update range indicator
	if range_indicator:
		range_indicator.scale = Vector2.ONE * (range_radius / 60.0)
	
	print("⬆️ ", tower_name, " upgraded to level ", level)

func _update_upgrade_visuals():
	"""Update visual indicators for upgrade level"""
	# Change sprite tint based on level
	if sprite:
		match level:
			2:
				sprite.modulate = Color(1.2, 1.2, 1.0, 1.0)  # Slightly brighter
			3:
				sprite.modulate = Color(1.4, 1.4, 1.0, 1.0)  # Much brighter
	
	# Show upgrade indicator
	if upgrade_indicator:
		upgrade_indicator.visible = level > 1

# 📡 Signal Handlers
func _on_enemy_entered_range(body):
	"""Handle enemy entering range"""
	if body is BaseEnemy:
		var enemy = body as BaseEnemy
		if not enemies_in_range.has(enemy):
			enemies_in_range.append(enemy)

func _on_enemy_exited_range(body):
	"""Handle enemy leaving range"""
	if body is BaseEnemy:
		var enemy = body as BaseEnemy
		enemies_in_range.erase(enemy)
		
		# Clear target if it left range
		if current_target == enemy:
			current_target = null

func _on_fire_timer_timeout():
	"""Handle fire timer timeout"""
	can_fire = true

# 🎨 Visual Helpers
func show_range_indicator():
	"""Show tower range visually"""
	if range_indicator:
		range_indicator.visible = true

func hide_range_indicator():
	"""Hide tower range indicator"""
	if range_indicator:
		range_indicator.visible = false

# 🎮 Public API
func get_tower_info() -> Dictionary:
	"""Get tower information"""
	return {
		"name": tower_name,
		"type": tower_type,
		"level": level,
		"damage": damage,
		"fire_rate": fire_rate,
		"range": range_radius,
		"upgrade_cost": get_upgrade_cost() if can_upgrade() else -1,
		"can_upgrade": can_upgrade(),
		"enemies_killed": enemies_killed,
		"total_damage": total_damage_dealt
	}

func set_target_priority(new_priority: TargetPriority):
	"""Set targeting priority"""
	target_priority = new_priority
	current_target = null  # Force retargeting

func get_material_type() -> String:
	"""Get material type for EcoPuntos integration"""
	match tower_type:
		Constants.TowerType.PLASTIC:
			return "plastic"
		Constants.TowerType.GLASS:
			return "glass"
		Constants.TowerType.PAPER:
			return "paper"
		Constants.TowerType.METAL:
			return "metal"
		_:
			return "plastic"