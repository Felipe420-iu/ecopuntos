extends CharacterBody2D
class_name BaseEnemy

# ===================================
# EcoPuntos Tower Defense - Base Enemy
# ===================================

signal enemy_died(enemy_type: Constants.EnemyType, money_reward: int, score_reward: int)
signal enemy_reached_end
signal enemy_damaged(damage_amount: int)

# 🧬 Enemy Properties
@export var enemy_type: Constants.EnemyType = Constants.EnemyType.PLASTIC_WASTE
@export var max_health: int = 100
@export var move_speed: float = 80.0
@export var money_reward: int = 15
@export var score_reward: int = 10
@export var damage_to_base: int = 1

# 🏃‍♂️ Movement
var current_health: int
var path_to_follow: Path2D
var path_follow: PathFollow2D
var move_direction: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0
var is_moving: bool = true

# 🎯 Combat
var is_dying: bool = false
var death_animation_duration: float = 0.5
var damage_flash_duration: float = 0.2

# 🎨 Visual Components
@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_number_scene = preload("res://scenes/effects/DamageNumber.tscn")

# 💥 Effects
@onready var hit_particles: CPUParticles2D = $HitParticles
@onready var death_particles: CPUParticles2D = $DeathParticles
@onready var status_effects: Node2D = $StatusEffects

func _ready():
	# Initialize health
	current_health = max_health
	_update_health_bar()
	
	# Setup visual components
	_setup_enemy_visuals()
	
	# Connect to path if available
	_setup_path_following()
	
	print("👾 ", get_enemy_name(), " enemy spawned with ", max_health, " HP")

func _setup_enemy_visuals():
	"""Setup enemy visual appearance"""
	# This will be overridden in child classes
	pass

func _setup_path_following():
	"""Setup path following for enemy movement"""
	# Find the path in the scene
	var level_node = get_tree().get_first_node_in_group("level")
	if level_node:
		path_to_follow = level_node.get_node_or_null("EnemyPath")
		
		if path_to_follow:
			# Create PathFollow2D for smooth path movement
			path_follow = PathFollow2D.new()
			path_to_follow.add_child(path_follow)
			
			# Position enemy at start of path
			global_position = path_follow.global_position

func _physics_process(delta):
	if not is_dying and is_moving:
		_move_along_path(delta)

func _move_along_path(delta):
	"""Move enemy along the designated path"""
	if not path_follow or not path_to_follow:
		_move_towards_target(delta)
		return
	
	# Move along path
	var curve = path_to_follow.curve
	if curve:
		distance_traveled += move_speed * delta
		path_follow.progress = distance_traveled
		
		# Update enemy position
		global_position = path_follow.global_position
		
		# Check if reached end of path
		if path_follow.progress_ratio >= 1.0:
			_reach_end_of_path()
		else:
			# Calculate movement direction for sprite orientation
			var progress_ahead = min(distance_traveled + 10, curve.get_baked_length())
			var future_pos = curve.sample_baked(progress_ahead)
			var current_pos = curve.sample_baked(distance_traveled)
			move_direction = (future_pos - current_pos).normalized()
			
			_update_sprite_direction()

func _move_towards_target(delta):
	"""Fallback movement when no path is available"""
	# Move towards the right side of the screen as default
	var target = Vector2(get_viewport().size.x + 100, global_position.y)
	var direction = (target - global_position).normalized()
	
	velocity = direction * move_speed
	move_and_slide()
	
	# Check if reached target
	if global_position.x >= get_viewport().size.x:
		_reach_end_of_path()

func _update_sprite_direction():
	"""Update sprite direction based on movement"""
	if move_direction.x < 0:
		sprite.scale.x = -abs(sprite.scale.x)  # Face left
	else:
		sprite.scale.x = abs(sprite.scale.x)   # Face right

func take_damage(damage: int, source_position: Vector2 = Vector2.ZERO):
	"""Take damage from towers/projectiles"""
	if is_dying:
		return
	
	current_health -= damage
	current_health = max(0, current_health)
	
	# Emit damage signal
	enemy_damaged.emit(damage)
	
	# Update health bar
	_update_health_bar()
	
	# Show damage number
	_show_damage_number(damage, source_position)
	
	# Visual feedback
	_play_damage_effect()
	
	# Check if enemy is dead
	if current_health <= 0:
		die()
	else:
		# Play hit animation
		if animation_player and animation_player.has_animation("hit"):
			animation_player.play("hit")

func die():
	"""Handle enemy death"""
	if is_dying:
		return
	
	is_dying = true
	is_moving = false
	
	# Disable collision
	collision_shape.disabled = true
	
	# Play death effects
	_play_death_effects()
	
	# Emit death signal
	enemy_died.emit(enemy_type, money_reward, score_reward)
	
	# Play death animation and cleanup
	_animate_death()
	
	print("💀 ", get_enemy_name(), " enemy died!")

func _play_damage_effect():
	"""Play damage visual effect"""
	# Flash red
	if sprite:
		var tween = create_tween()
		tween.tween_method(_set_sprite_modulate, Color.WHITE, Color.RED, damage_flash_duration * 0.5)
		tween.tween_method(_set_sprite_modulate, Color.RED, Color.WHITE, damage_flash_duration * 0.5)
	
	# Particle effect
	if hit_particles:
		hit_particles.emitting = true

func _play_death_effects():
	"""Play death visual effects"""
	# Death particles
	if death_particles:
		death_particles.emitting = true
	
	# Screen shake (if available)
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("add_screen_shake"):
		game_manager.add_screen_shake(3.0, 0.2)

func _animate_death():
	"""Animate enemy death and cleanup"""
	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0.0, death_animation_duration)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, death_animation_duration)
	tween.tween_callback(_cleanup_enemy)

func _cleanup_enemy():
	"""Clean up enemy node"""
	# Remove from path if following
	if path_follow and is_instance_valid(path_follow):
		path_follow.queue_free()
	
	# Remove self
	queue_free()

func _reach_end_of_path():
	"""Handle enemy reaching the end of the path"""
	enemy_reached_end.emit()
	_cleanup_enemy()

func _update_health_bar():
	"""Update health bar display"""
	if health_bar:
		var health_percentage = float(current_health) / float(max_health)
		health_bar.value = health_percentage * 100
		
		# Color coding for health
		if health_percentage > 0.7:
			health_bar.modulate = Color.GREEN
		elif health_percentage > 0.3:
			health_bar.modulate = Color.YELLOW
		else:
			health_bar.modulate = Color.RED
		
		# Hide health bar when at full health
		health_bar.visible = current_health < max_health

func _show_damage_number(damage: int, source_position: Vector2):
	"""Show floating damage number"""
	if damage_number_scene:
		var damage_number = damage_number_scene.instantiate()
		get_tree().current_scene.add_child(damage_number)
		damage_number.global_position = global_position + Vector2(0, -20)
		damage_number.setup_damage(damage, source_position)

func _set_sprite_modulate(color: Color):
	"""Helper function for tween modulation"""
	if sprite:
		sprite.modulate = color

# 🎯 Status Effects
func apply_slow_effect(slow_percentage: float, duration: float):
	"""Apply slow status effect"""
	var original_speed = move_speed
	move_speed *= (1.0 - slow_percentage)
	
	# Visual indicator
	modulate = Color(0.7, 0.7, 1.0, 1.0)
	
	# Remove effect after duration
	await get_tree().create_timer(duration).timeout
	move_speed = original_speed
	modulate = Color.WHITE

func apply_poison_effect(damage_per_second: int, duration: float):
	"""Apply poison status effect"""
	var elapsed_time = 0.0
	var tick_interval = 1.0
	
	# Visual indicator
	modulate = Color(0.7, 1.0, 0.7, 1.0)
	
	while elapsed_time < duration and not is_dying:
		await get_tree().create_timer(tick_interval).timeout
		if not is_dying:
			take_damage(damage_per_second)
		elapsed_time += tick_interval
	
	# Remove visual effect
	if not is_dying:
		modulate = Color.WHITE

# 🎮 Utility Functions
func get_enemy_name() -> String:
	"""Get friendly name for enemy type"""
	match enemy_type:
		Constants.EnemyType.PLASTIC_WASTE:
			return "Plastic Waste"
		Constants.EnemyType.GLASS_WASTE:
			return "Glass Waste"
		Constants.EnemyType.PAPER_WASTE:
			return "Paper Waste"
		Constants.EnemyType.METAL_WASTE:
			return "Metal Waste"
		Constants.EnemyType.BOSS_WASTE:
			return "Boss Waste"
		_:
			return "Unknown Enemy"

func get_health_percentage() -> float:
	"""Get current health as percentage"""
	return float(current_health) / float(max_health)

func is_at_full_health() -> bool:
	"""Check if enemy is at full health"""
	return current_health >= max_health

func get_distance_to_end() -> float:
	"""Get distance remaining to end of path"""
	if path_follow and path_to_follow:
		var total_length = path_to_follow.curve.get_baked_length()
		return total_length - distance_traveled
	return 0.0

# 💡 Override in child classes for specific enemy behaviors
func _on_spawn():
	"""Called when enemy is spawned - override in child classes"""
	pass

func _on_death():
	"""Called when enemy dies - override in child classes"""
	pass
