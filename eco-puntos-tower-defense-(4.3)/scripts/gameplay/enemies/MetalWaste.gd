extends CharacterBody2D
class_name MetalWaste

## EcoPuntos Tower Defense - Metal Waste Enemy

var enemy_type: int
var max_health: float = 150.0
var current_health: float
var move_speed: float = 40.0
var money_reward: int = 25
var score_reward: int = 15
var damage_to_base: int = 3

var sprite: Sprite2D
var hit_particles: GPUParticles2D
var death_particles: GPUParticles2D

func _ready():
    if Engine.has_singleton("Constants"):
        var C = Engine.get_singleton("Constants")
        enemy_type = C.EnemyType.METAL_WASTE
        max_health = 150
        move_speed = 40.0
        money_reward = 25
        var val = C.get("POINTS_PER_METAL_ENEMY")
        score_reward = val if val != null else 15
        damage_to_base = 3
    else:
        enemy_type = 4
        max_health = 150
        move_speed = 40.0
        money_reward = 25
        score_reward = 15
        damage_to_base = 3

    current_health = max_health

    sprite = $Sprite2D if has_node("Sprite2D") else null
    hit_particles = $HitParticles if has_node("HitParticles") else null
    death_particles = $DeathParticles if has_node("DeathParticles") else null

    _setup_enemy_visuals()

func _setup_enemy_visuals():
    if sprite:
        sprite.modulate = Color(0.8, 0.8, 0.9, 1.0) # metallic tint
    if hit_particles:
        hit_particles.color = Color(0.8,0.8,0.9)
    if death_particles:
        death_particles.color = Color(0.8,0.8,0.9)

func _on_spawn():
    print("🛠️ Metal waste spawned - heavy and slow")

func _on_death():
    if death_particles:
        death_particles.emitting = true
