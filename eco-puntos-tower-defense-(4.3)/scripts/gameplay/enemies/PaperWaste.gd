extends CharacterBody2D
class_name PaperWaste

## EcoPuntos Tower Defense - Paper Waste Enemy

var enemy_type: int
var max_health: float = 90.0
var current_health: float
var move_speed: float = 70.0
var money_reward: int = 12
var score_reward: int = 6
var damage_to_base: int = 1

var sprite: Sprite2D
var hit_particles: GPUParticles2D
var death_particles: GPUParticles2D

func _ready():
    if Engine.has_singleton("Constants"):
        var C = Engine.get_singleton("Constants")
        enemy_type = C.EnemyType.PAPER_WASTE
        max_health = 90
        move_speed = 70.0
        money_reward = 12
        var val = C.get("POINTS_PER_PAPER_ENEMY")
        score_reward = val if val != null else 6
        damage_to_base = 1
    else:
        enemy_type = 3
        max_health = 90
        move_speed = 70.0
        money_reward = 12
        score_reward = 6
        damage_to_base = 1

    current_health = max_health

    sprite = $Sprite2D if has_node("Sprite2D") else null
    hit_particles = $HitParticles if has_node("HitParticles") else null
    death_particles = $DeathParticles if has_node("DeathParticles") else null

    _setup_enemy_visuals()

func _setup_enemy_visuals():
    if sprite:
        sprite.modulate = Color(0.95, 0.95, 0.8, 1.0) # paper-like beige
    if hit_particles:
        hit_particles.color = Color(0.95,0.95,0.8)
    if death_particles:
        death_particles.color = Color(0.95,0.95,0.8)

func _on_spawn():
    print("📄 Paper waste spawned - light and fluttery")

func _on_death():
    if death_particles:
        death_particles.emitting = true
