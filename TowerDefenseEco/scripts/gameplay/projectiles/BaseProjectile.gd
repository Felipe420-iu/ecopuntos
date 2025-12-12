extends RigidBody2D
class_name BaseProjectile

# ===================================
# EcoPuntos Tower Defense - Base Projectile
# ===================================

signal projectile_hit(target: BaseEnemy, damage: int)
signal projectile_expired

# 🚀 Projectile Properties
@export var projectile_type: Constants.ProjectileType = Constants.ProjectileType.RECYCLE_BULLET
@export var base_damage: int = 25
@export var move_speed: float = 300.0
@export var lifetime: float = 3.0
@export var pierce_count: int = 0  # How many enemies it can go through
@export var splash_radius: float = 0.0  # 0 = no splash damage
@export var splash_damage_multiplier: float = 0.5

# 🎯 Targeting
var target_enemy: BaseEnemy
var target_position: Vector2
var source_tower: BaseTower
var current_damage: int
var is_homing: bool = false
var has_hit_target: bool = false

# 📊 Tracking
var enemies_pierced: Array[BaseEnemy] = []
var distance_traveled: float = 0.0

# 🎨 Visual Components  
@onready var sprite: Sprite2D = $Sprite2D
@onready var trail_particles: CPUParticles2D = $TrailParticles
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_area: Area2D = $HitArea
@onready var hit_area_collision: CollisionShape2D = $HitArea/CollisionShape2D
@onready var lifetime_timer: Timer = $LifetimeTimer

# 💥 Effects
@onready var impact_particles: CPUParticles2D = $ImpactParticles
@onready var splash_particles: CPUParticles2D = $SplashParticles

func _ready():
	# Setup projectile
	_setup_projectile_visuals()
	_setup_collision()
	_setup_lifetime_timer()
	
	# Connect signals
	_connect_signals()
	
	# Setup physics
	gravity_scale = 0.0  # No gravity for projectiles
	
	print("🚀 Projectile fired: ", get_projectile_name())

func _setup_projectile_visuals():
	"""Setup projectile visual appearance - override in child classes"""
	if trail_particles:
		trail_particles.emitting = true

func _setup_collision():
	"""Setup collision detection"""
	if hit_area:
		# Connect area signals
		hit_area.body_entered.connect(_on_body_entered)
		hit_area.area_entered.connect(_on_area_entered)

func _setup_lifetime_timer():
	"""Setup projectile lifetime"""
	if lifetime_timer:
		lifetime_timer.wait_time = lifetime
		lifetime_timer.one_shot = true
		lifetime_timer.timeout.connect(_on_lifetime_expired)
		lifetime_timer.start()

func _connect_signals():
	"""Connect projectile signals"""
	body_entered.connect(_on_collision_body_entered)

func setup_projectile(target: BaseEnemy, damage: int, speed: float, tower: BaseTower):
	"""Setup projectile to track a specific enemy"""
	target_enemy = target
	target_position = target.global_position
	current_damage = damage
	move_speed = speed
	source_tower = tower
	is_homing = true
	
	# Set initial direction
	if target_enemy:
		var direction = (target_enemy.global_position - global_position).normalized()
		linear_velocity = direction * move_speed
		_update_rotation()

func setup_projectile_to_position(target_pos: Vector2, damage: int, speed: float, tower: BaseTower):
	"""Setup projectile to move to a specific position"""
	target_position = target_pos
	current_damage = damage
	move_speed = speed
	source_tower = tower
	is_homing = false
	
	# Set direction to target position
	var direction = (target_position - global_position).normalized()
	linear_velocity = direction * move_speed
	_update_rotation()

func _physics_process(delta):
	if is_homing and target_enemy and is_instance_valid(target_enemy) and not target_enemy.is_dying:
		_home_to_target(delta)
	
	_update_distance_traveled(delta)
	_update_rotation()

func _home_to_target(delta):
	"""Update trajectory to home in on target"""
	if not target_enemy or target_enemy.is_dying:
		return
	
	var direction_to_target = (target_enemy.global_position - global_position).normalized()
	var current_direction = linear_velocity.normalized()
	
	# Blend current direction with target direction for smooth homing
	var homing_strength = 0.8
	var new_direction = current_direction.lerp(direction_to_target, homing_strength * delta)
	
	linear_velocity = new_direction.normalized() * move_speed

func _update_distance_traveled(delta):
	"""Track distance traveled"""
	distance_traveled += linear_velocity.length() * delta

func _update_rotation():
	"""Update projectile rotation to match movement direction"""
	if linear_velocity.length() > 0:
		rotation = linear_velocity.angle()

func _on_body_entered(body):
	"""Handle collision with enemy"""
	if body is BaseEnemy:
		var enemy = body as BaseEnemy
		_hit_enemy(enemy)

func _on_collision_body_entered(body):
	"""Handle direct collision"""
	if body is BaseEnemy:
		var enemy = body as BaseEnemy
		_hit_enemy(enemy)

func _hit_enemy(enemy: BaseEnemy):
	"""Handle hitting an enemy"""
	if enemy.is_dying or enemies_pierced.has(enemy):
		return
	
	# Apply damage
	var final_damage = _calculate_damage(enemy)
	enemy.take_damage(final_damage, global_position)
	
	# Track the hit
	enemies_pierced.append(enemy)
	projectile_hit.emit(enemy, final_damage)
	
	# Play hit effects
	_play_hit_effects(enemy)
	
	# Handle splash damage
	if splash_radius > 0.0:
		_apply_splash_damage(enemy)
	
	# Check if projectile should be destroyed
	if pierce_count <= 0 or enemies_pierced.size() > pierce_count:
		_destroy_projectile()
	
	print("💥 Projectile hit ", enemy.get_enemy_name(), " for ", final_damage, " damage")

func _calculate_damage(enemy: BaseEnemy) -> int:
	"""Calculate final damage against specific enemy"""
	var final_damage = current_damage
	
	# Apply tower-specific effectiveness if available
	if source_tower and source_tower.has_method("get_effectiveness_against"):
		var effectiveness = source_tower.get_effectiveness_against(enemy.enemy_type)
		final_damage = int(final_damage * effectiveness)
	
	# Apply projectile-specific modifiers
	final_damage = int(final_damage * _get_damage_modifier(enemy))
	
	return final_damage

func _get_damage_modifier(enemy: BaseEnemy) -> float:
	"""Get projectile-specific damage modifier - override in child classes"""
	return 1.0

func _apply_splash_damage(epicenter_enemy: BaseEnemy):
	"""Apply splash damage around impact point"""
	var enemies_in_splash = _get_enemies_in_radius(global_position, splash_radius)
	
	for enemy in enemies_in_splash:
		if enemy == epicenter_enemy or enemy.is_dying:
			continue
		
		var splash_damage = int(current_damage * splash_damage_multiplier)
		enemy.take_damage(splash_damage, global_position)
	
	# Play splash effects
	_play_splash_effects()

func _get_enemies_in_radius(center: Vector2, radius: float) -> Array[BaseEnemy]:
	"""Get all enemies within a radius"""
	var enemies: Array[BaseEnemy] = []
	var enemy_manager = get_tree().get_first_node_in_group("enemy_manager")
	
	if enemy_manager and enemy_manager.has_method("get_all_enemies"):
		var all_enemies = enemy_manager.get_all_enemies()
		for enemy in all_enemies:
			if enemy and is_instance_valid(enemy) and not enemy.is_dying:
				var distance = center.distance_to(enemy.global_position)
				if distance <= radius:
					enemies.append(enemy)
	
	return enemies

func _play_hit_effects(enemy: BaseEnemy):
	"""Play visual effects when hitting enemy"""
	if impact_particles:
		impact_particles.global_position = global_position
		impact_particles.emitting = true
	
	# Screen shake for powerful impacts
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("add_screen_shake"):
		game_manager.add_screen_shake(2.0, 0.15)

func _play_splash_effects():
	"""Play splash damage visual effects"""
	if splash_particles:
		splash_particles.global_position = global_position
		splash_particles.emitting = true
	
	# Create splash damage indicator
	_create_splash_indicator()

func _create_splash_indicator():
	"""Create visual indicator for splash damage area"""
	var splash_indicator = ColorRect.new()
	splash_indicator.size = Vector2(splash_radius * 2, splash_radius * 2)
	splash_indicator.position = global_position - splash_indicator.size / 2
	splash_indicator.color = Color(1.0, 0.5, 0.0, 0.3)
	splash_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	get_tree().current_scene.add_child(splash_indicator)
	
	# Fade out splash indicator
	var tween = create_tween()
	tween.tween_property(splash_indicator, "modulate:a", 0.0, 0.5)
	tween.tween_callback(splash_indicator.queue_free)

func _destroy_projectile():
	"""Destroy the projectile"""
	has_hit_target = true
	
	# Stop trail particles
	if trail_particles:
		trail_particles.emitting = false
	
	# Play destruction effects
	_play_destruction_effects()
	
	# Emit signal
	projectile_expired.emit()
	
	# Remove projectile after brief delay for effects
	await get_tree().create_timer(0.3).timeout
	queue_free()

func _play_destruction_effects():
	"""Play effects when projectile is destroyed"""
	# Override in child classes for specific effects
	pass

func _on_lifetime_expired():
	"""Handle projectile lifetime expiration"""
	print("⏰ Projectile expired after ", lifetime, " seconds")
	_destroy_projectile()

# 🎮 Utility Functions
func get_projectile_name() -> String:
	"""Get friendly name for projectile type"""
	match projectile_type:
		Constants.ProjectileType.RECYCLE_BULLET:
			return "Recycle Bullet"
		Constants.ProjectileType.CLEAN_BEAM:
			return "Clean Beam"
		Constants.ProjectileType.ECO_BOMB:
			return "Eco Bomb"
		_:
			return "Unknown Projectile"

func get_distance_to_target() -> float:
	"""Get distance to target"""
	if target_enemy and is_instance_valid(target_enemy):
		return global_position.distance_to(target_enemy.global_position)
	elif target_position != Vector2.ZERO:
		return global_position.distance_to(target_position)
	return 0.0

func is_still_tracking() -> bool:
	"""Check if projectile is still tracking its target"""
	return is_homing and target_enemy and is_instance_valid(target_enemy) and not target_enemy.is_dying

# 📊 Statistics
func get_projectile_stats() -> Dictionary:
	"""Get projectile statistics"""
	return {
		"type": projectile_type,
		"damage": current_damage,
		"speed": move_speed,
		"distance_traveled": distance_traveled,
		"enemies_hit": enemies_pierced.size(),
		"has_splash": splash_radius > 0.0,
		"can_pierce": pierce_count > 0
	}