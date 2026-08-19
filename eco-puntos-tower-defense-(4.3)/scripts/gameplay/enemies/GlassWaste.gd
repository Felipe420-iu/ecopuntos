extends CharacterBody2D
class_name GlassWaste

## EcoPuntos Tower Defense - Glass Waste Enemy

var enemy_type: int
var max_health: float = 120.0
var current_health: float
var move_speed: float = 60.0
var money_reward: int = 20
var score_reward: int = 10
var damage_to_base: int = 2

var sprite: Sprite2D
var hit_particles: GPUParticles2D
var death_particles: GPUParticles2D

func _ready():
	# Prefer getting values from the autoload `Constants` if available
	if Engine.has_singleton("Constants"):
		var C = Engine.get_singleton("Constants")
		enemy_type = C.EnemyType.GLASS_WASTE
		max_health = 120
		move_speed = 60.0
		money_reward = 20
		var val = C.get("POINTS_PER_GLASS_ENEMY")
		score_reward = val if val != null else 10
		damage_to_base = 2
	else:
		enemy_type = 2
		max_health = 120
		move_speed = 60.0
		money_reward = 20
		score_reward = 10
		damage_to_base = 2

	current_health = max_health

	sprite = $Sprite2D if has_node("Sprite2D") else null
	hit_particles = $HitParticles if has_node("HitParticles") else null
	death_particles = $DeathParticles if has_node("DeathParticles") else null

	_setup_enemy_visuals()

func _setup_enemy_visuals():
	if sprite:
		sprite.modulate = Color(0.6, 0.9, 0.9, 1.0) # bluish glass tint
	if hit_particles:
		hit_particles.color = Color(0.6,0.9,0.9)
	if death_particles:
		death_particles.color = Color(0.6,0.9,0.9)

func _on_spawn():
	print("🧊 Glass waste spawned - fragile but tougher")

func _on_death():
	# Shards effect or similar
	if death_particles:
		death_particles.emitting = true
