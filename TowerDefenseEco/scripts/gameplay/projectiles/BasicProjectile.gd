extends CharacterBody2D
class_name BasicProjectile

# ===================================
# EcoPuntos Tower Defense - Basic Projectile
# ===================================

## 💥 Projectile Properties
@export var speed: float = 300.0
@export var damage: float = 25.0
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 3.0

## 🎯 Target
var target_enemy: CharacterBody2D = null
var is_homing: bool = true
var max_range: float = 500.0
var distance_traveled: float = 0.0

## 🎨 Visual
@onready var visual: Node2D = $Visual if has_node("Visual") else null

func _ready():
	print("🚀 Projectile fired")
	collision_layer = 0
	collision_mask = 1 << 1  # hit enemies layer
	
	# Auto-destroy after lifetime
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta):
	_move_projectile(delta)
	_check_collision()

func _move_projectile(delta):
	"""Move projectile towards target or in direction"""
	var move_direction = direction
	
	# Homing behavior if target exists
	if is_homing and target_enemy and is_instance_valid(target_enemy):
		var target_pos = target_enemy.global_position
		move_direction = (target_pos - global_position).normalized()
	
	# Move projectile
	velocity = move_direction * speed
	move_and_slide()
	
	# Track distance
	distance_traveled += speed * delta
	if distance_traveled > max_range:
		queue_free()

func _check_collision():
	"""Check for collision with enemies"""
	# Simple collision detection with get_slide_collision
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.has_method("take_damage"):
			_hit_enemy(collider)
			return

func _hit_enemy(enemy):
	"""Handle hitting an enemy"""
	print("💥 Projectile hit enemy!")
	
	# Deal damage
	enemy.take_damage(damage)
	
	# Create hit effect
	_create_hit_effect()
	
	# Destroy projectile
	queue_free()

func _create_hit_effect():
	"""Create visual hit effect"""
	# Simple flash effect
	modulate = Color.WHITE
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.YELLOW, 0.1)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)