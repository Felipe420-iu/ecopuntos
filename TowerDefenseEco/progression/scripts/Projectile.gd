extends CharacterBody2D
class_name Projectile

const LEVELS := {
	1: {"texture": "res://assets/desert_pack/bullets/balas.png", "speed": 260.0, "damage": 20.0},
	2: {"texture": "res://assets/desert_pack/bullets/balas..png", "speed": 320.0, "damage": 28.0},
	3: {"texture": "res://assets/desert_pack/bullets/balas....png", "speed": 380.0, "damage": 38.0},
	4: {"texture": "res://assets/desert_pack/bullets/balas.....png", "speed": 460.0, "damage": 52.0},
}

var level: int = 1
var damage: float = 0.0
var target: Node2D = null
var max_range: float = 900.0
var distance_traveled: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func setup(p_level: int, p_target: Node2D, base_damage: float):
	level = clamp(p_level, 1, 4)
	target = p_target
	var data = LEVELS[level]
	damage = base_damage
	sprite.texture = _load_texture_or_placeholder(data["texture"], Color(1.0, 0.8, 0.2))
	var shape := CircleShape2D.new()
	shape.radius = 6.0
	collision_shape.shape = shape
	set_physics_process(true)

func _physics_process(delta):
	if not target or not is_instance_valid(target):
		queue_free()
		return
	var data = LEVELS[level]
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * data["speed"]
	var collision = move_and_collide(velocity * delta)
	if collision:
		var col = collision.get_collider()
		if col and col.has_method("take_damage"):
			col.take_damage(damage)
		queue_free()
	distance_traveled += velocity.length() * delta
	if distance_traveled > max_range:
		queue_free()

func _load_texture_or_placeholder(path: String, color: Color) -> Texture2D:
	var tex = ResourceLoader.load(path) as Texture2D
	if tex:
		return tex
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)
