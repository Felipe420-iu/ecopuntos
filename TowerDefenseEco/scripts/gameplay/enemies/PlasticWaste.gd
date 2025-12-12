extends CharacterBody2D
class_name PlasticWaste

# ===================================
# EcoPuntos Tower Defense - Plastic Waste Enemy
# ===================================

## 🏷️ Enemy Properties (from BaseEnemy)
var enemy_type: int
var max_health: float = 100.0
var current_health: float
var move_speed: float = 50.0
var money_reward: int = 10
var score_reward: int = 5
var damage_to_base: int = 1

## 🎨 Visual Components
var sprite: Sprite2D
var hit_particles: GPUParticles2D
var death_particles: GPUParticles2D

func _ready():
	# Set plastic waste specific properties
	enemy_type = Constants.EnemyType.PLASTIC_WASTE
	max_health = 80
	move_speed = 90.0
	money_reward = 15
	score_reward = Constants.POINTS_PER_PLASTIC_ENEMY
	damage_to_base = 1
	
	# Initialize health
	current_health = max_health
	
	# Get node references (safe)
	sprite = $Sprite2D if has_node("Sprite2D") else null
	hit_particles = $HitParticles if has_node("HitParticles") else null
	death_particles = $DeathParticles if has_node("DeathParticles") else null
	
	# Setup visuals
	_setup_enemy_visuals()

func _setup_enemy_visuals():
	"""Setup plastic waste specific visuals"""
	# Set sprite color to plastic-like colors
	if sprite:
		sprite.modulate = Color(0.9, 0.9, 0.3, 1.0)  # Yellowish plastic
	
	# Setup particles for plastic
	if hit_particles:
		hit_particles.color = Color.YELLOW
		hit_particles.emission_rate = 20.0
	
	if death_particles:
		death_particles.color = Color.YELLOW
		death_particles.emission_rate = 50.0

func _on_spawn():
	"""Plastic waste specific spawn behavior"""
	print("🧃 Plastic waste spawned - lightweight and fast!")

func _on_death():
	"""Plastic waste specific death behavior"""
	# Plastic breaks into smaller pieces
	_create_plastic_fragments()

func _create_plastic_fragments():
	"""Create visual fragments when plastic waste is destroyed"""
	for i in range(3):
		var fragment = _create_fragment()
		if fragment:
			get_parent().add_child(fragment)
			fragment.global_position = global_position
			
			# Random direction for fragments
			var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			fragment.apply_impulse(random_direction * 100)

func _create_fragment() -> RigidBody2D:
	"""Create a small plastic fragment"""
	var fragment = RigidBody2D.new()
	
	# Add sprite
	var sprite_node = Sprite2D.new()
	sprite_node.modulate = Color.YELLOW
	fragment.add_child(sprite_node)
	
	# Add collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 5
	collision.shape = shape
	fragment.add_child(collision)
	
	# Auto-remove after 2 seconds
	fragment.tree_exiting.connect(func(): fragment.queue_free())
	get_tree().create_timer(2.0).timeout.connect(func(): fragment.queue_free())
	
	return fragment
