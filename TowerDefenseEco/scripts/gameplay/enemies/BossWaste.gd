extends CharacterBody2D
class_name BossWaste

## EcoPuntos Tower Defense - Boss Waste Enemy

var enemy_type: int
var max_health: float = 500.0
var current_health: float
var move_speed: float = 30.0
var money_reward: int = 100
var score_reward: int = 200
var damage_to_base: int = 10

var sprite: Sprite2D
var hit_particles: GPUParticles2D
var death_particles: GPUParticles2D

func _ready():
    if Engine.has_singleton("Constants"):
        var C = Engine.get_singleton("Constants")
        enemy_type = C.EnemyType.BOSS_WASTE
        max_health = 500
        move_speed = 30.0
        money_reward = 100
        var val = C.get("POINTS_PER_BOSS_ENEMY")
        score_reward = val if val != null else 200
        damage_to_base = 10
    else:
        enemy_type = 99
        max_health = 500
        move_speed = 30.0
        money_reward = 100
        score_reward = 200
        damage_to_base = 10

    current_health = max_health

    sprite = $Sprite2D if has_node("Sprite2D") else null
    hit_particles = $HitParticles if has_node("HitParticles") else null
    death_particles = $DeathParticles if has_node("DeathParticles") else null

    _setup_enemy_visuals()

func _setup_enemy_visuals():
    if sprite:
        sprite.modulate = Color(1.0, 0.6, 0.6, 1.0) # boss tint
    if hit_particles:
        hit_particles.color = Color(1.0,0.6,0.6)
    if death_particles:
        death_particles.color = Color(1.0,0.6,0.6)

func _on_spawn():
    print("👑 Boss waste spawned - watch out!")

func _on_death():
    if death_particles:
        death_particles.emitting = true
