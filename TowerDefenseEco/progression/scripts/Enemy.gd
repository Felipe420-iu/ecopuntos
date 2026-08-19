extends CharacterBody2D
class_name Enemy

signal enemy_died(reward: int)
signal enemy_reached_end

const STATE_SPAWN := "spawn"
const STATE_IDLE := "idle"
const STATE_MOVE := "move"
const STATE_ATTACK := "attack"
const STATE_HIT := "hit"
const STATE_DEAD := "dead"

const LEVELS := {
	1: {"texture": "res://assets/desert_pack/enemies/enemy_def_0.png", "health": 120.0, "speed": 80.0, "reward": 12},
	2: {"texture": "res://assets/desert_pack/enemies/enemy_def_1.png", "health": 170.0, "speed": 95.0, "reward": 16},
	3: {"texture": "res://assets/desert_pack/enemies/enemy_def_2.png", "health": 240.0, "speed": 110.0, "reward": 22},
}

var level: int = 1
var max_health: float = 100.0
var current_health: float = 100.0
var move_speed: float = 80.0
var reward: int = 10
var direction: Vector2 = Vector2.RIGHT
var target_x: float = 1200.0
var state: String = STATE_SPAWN
var base_sprite_position: Vector2 = Vector2.ZERO
var base_scale: Vector2 = Vector2(1.2, 1.2)
var _hit_tween: Tween
var _death_tween: Tween

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_particles: CPUParticles2D = $HitParticles
@onready var death_particles: CPUParticles2D = $DeathParticles

func _ready():
	sprite = get_node_or_null("Sprite2D")
	collision_shape = get_node_or_null("CollisionShape2D")
	hit_particles = get_node_or_null("HitParticles")
	death_particles = get_node_or_null("DeathParticles")
	add_to_group("enemies")
	collision_layer = 1 << 1
	collision_mask = 1 << 2
	base_sprite_position = sprite.position if sprite else Vector2.ZERO
	if hit_particles:
		hit_particles.emitting = false
	if death_particles:
		death_particles.emitting = false
	sprite.scale = base_scale
	sprite.modulate.a = 0.15
	set_physics_process(false)
	_animate_spawn()

func setup(p_level: int, health_mult: float, speed_mult: float):
	level = clamp(p_level, 1, 3)
	var data = LEVELS[level]
	max_health = data["health"] * health_mult
	current_health = max_health
	move_speed = data["speed"] * speed_mult
	reward = data["reward"]
	var tex = _load_texture_or_placeholder(data["texture"], Color(0.9, 0.2, 0.2))
	if sprite:
		sprite.texture = tex
	if collision_shape:
		var shape := CircleShape2D.new()
		shape.radius = 16.0
		collision_shape.shape = shape
	set_physics_process(true)
	state = STATE_MOVE

func set_target_x(value: float):
	target_x = value

func _load_texture_or_placeholder(path: String, color: Color) -> Texture2D:
	var tex = ResourceLoader.load(path) as Texture2D
	if tex:
		return tex
	var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)

func _physics_process(delta):
	if not sprite:
		return
	if state == STATE_DEAD:
		return

	if global_position.x >= target_x - 24.0:
		state = STATE_ATTACK
		var anticipation: float = 1.0 - clamp((target_x - global_position.x) / 24.0, 0.0, 1.0)
		sprite.position.x = lerp(0.0, -12.0, anticipation)
		sprite.position.y = base_sprite_position.y + sin(Time.get_ticks_msec() * 0.03) * 4.0
		sprite.rotation = lerp(sprite.rotation, -0.18, 0.2)
		velocity = direction * move_speed * 0.35
		move_and_slide()
		if global_position.x >= target_x:
			enemy_reached_end.emit()
			set_physics_process(false)
			queue_free()
		return

	velocity = direction * move_speed
	move_and_slide()
	_apply_visual_motion(delta)

	if global_position.x >= target_x:
		enemy_reached_end.emit()
		set_physics_process(false)
		queue_free()

func _apply_visual_motion(delta: float) -> void:
	if not sprite:
		return
	if state == STATE_HIT:
		return

	var move_strength: float = clamp(velocity.length() / max(move_speed, 1.0), 0.15, 1.0)
	var walk_phase: float = Time.get_ticks_msec() * 0.008
	if move_strength > 0.25:
		state = STATE_MOVE
		var walk_offset: float = sin(walk_phase * 16.0) * (4.0 + move_strength * 5.0)
		sprite.position.x = lerp(sprite.position.x, 0.0, 0.25)
		sprite.position.y = base_sprite_position.y + walk_offset
		sprite.rotation = sin(walk_phase * 10.0) * 0.14
		sprite.scale = Vector2(1.3 + sin(walk_phase * 8.0) * 0.14, 1.15 - sin(walk_phase * 8.0) * 0.09)
	else:
		state = STATE_IDLE
		var idle_phase: float = sin(walk_phase * 6.0)
		sprite.position.x = lerp(sprite.position.x, 0.0, 0.2)
		sprite.position.y = base_sprite_position.y + idle_phase * 3.0
		sprite.rotation = idle_phase * 0.09
		sprite.scale = Vector2(1.22 + idle_phase * 0.1, 1.16 - idle_phase * 0.07)

func _animate_spawn() -> void:
	if not sprite:
		return
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", base_scale, 0.18)
	tween.parallel().tween_property(sprite, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(sprite, "position:y", base_sprite_position.y - 24.0, 0.12)
	tween.tween_property(sprite, "position:y", base_sprite_position.y, 0.12)
	tween.finished.connect(func():
		if state == STATE_SPAWN:
			state = STATE_IDLE
	)

func take_damage(amount: float):
	if state == STATE_DEAD:
		return
	current_health -= amount
	state = STATE_HIT
	if hit_particles:
		hit_particles.restart()
		hit_particles.emitting = true
	if _hit_tween:
		_hit_tween.kill()
	_hit_tween = create_tween()
	_hit_tween.tween_property(sprite, "rotation", 0.26, 0.06)
	_hit_tween.tween_property(sprite, "rotation", 0.0, 0.12)
	_hit_tween.parallel().tween_property(sprite, "position:x", base_sprite_position.x - 14.0, 0.08)
	_hit_tween.tween_property(sprite, "position:x", base_sprite_position.x, 0.12)
	_hit_tween.parallel().tween_property(sprite, "modulate", Color(1.0, 0.35, 0.35, 1.0), 0.06)
	_hit_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)
	if current_health <= 0:
		_die()

func _die() -> void:
	if state == STATE_DEAD:
		return
	state = STATE_DEAD
	if death_particles:
		death_particles.restart()
		death_particles.emitting = true
	if _death_tween:
		_death_tween.kill()
	_death_tween = create_tween()
	_death_tween.tween_property(sprite, "rotation", 0.9, 0.12)
	_death_tween.parallel().tween_property(sprite, "scale", Vector2(1.5, 0.8), 0.12)
	_death_tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.22)
	_death_tween.parallel().tween_property(sprite, "position:y", base_sprite_position.y + 12.0, 0.18)
	_death_tween.finished.connect(func():
		enemy_died.emit(reward)
		set_physics_process(false)
		queue_free()
	)
