extends CharacterBody2D
class_name PlasticWaste

# ===================================
# EcoPuntos Tower Defense - Plastic Waste Enemy  
# ===================================

signal enemy_died(enemy_type: Constants.EnemyType, money_reward: int, score_reward: int)
signal enemy_reached_end(damage_to_base: int)

## 🏷️ Enemy Properties
var enemy_type: Constants.EnemyType = Constants.EnemyType.PLASTIC_WASTE
var max_health: float = 80.0
var current_health: float
var move_speed: float = 90.0
var money_reward: int = 15
var score_reward: int = 10
var damage_to_base: int = 1
var texture_variant_index: int = 0
var theme_color: Color = Color.WHITE

const VARIANT_TEXTURES := [
	"res://assets/desert_pack/enemies/enemy_def_0.png",
	"res://assets/desert_pack/enemies/enemy_def_1.png",
	"res://assets/desert_pack/enemies/enemy_def_2.png",
]

const WAVE_THEMES := [
	Color(0.55, 1.0, 0.65),
	Color(0.55, 0.8, 1.0),
	Color(1.0, 0.82, 0.5),
	Color(1.0, 0.66, 0.7),
	Color(0.9, 0.65, 1.0),
]

## 🏃‍♂️ Movement
var path_to_follow: Path2D
var path_follow: PathFollow2D
var progress_on_path: float = 0.0
var is_moving: bool = true
var is_dying: bool = false

## 🎨 Visual Components
@onready var visual_node = $Visual if has_node("Visual") else null
@onready var health_bar = $HealthBar if has_node("HealthBar") else null
@onready var collision_shape = $CollisionShape2D if has_node("CollisionShape2D") else null

func _ready():
	print("🧃 Plastic Waste enemy spawned")
	add_to_group("enemies")
	collision_layer = 1 << 1  # Enemy layer
	collision_mask = 0        # Don't collide with world for now; towers use Area2D mask
	# Make sure it's visible above background
	z_index = 10
	show()
	
	# Initialize health
	current_health = max_health
	
	# Setup collision shape
	_setup_collision()
	
	# Setup visuals
	_setup_visuals()
	
	# Update health bar
	_update_health_bar()

func _setup_collision():
	"""Setup collision shape for enemy"""
	if collision_shape and not collision_shape.shape:
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 15.0
		collision_shape.shape = circle_shape

func _setup_visuals():
	"""Setup visual appearance"""
	if visual_node:
		visual_node.scale = Vector2(1.28, 1.28)
		visual_node.z_index = 10
		visual_node.position = Vector2(0, -2)
		visual_node.modulate = theme_color
		_apply_visual_variant()
	
	# Setup health bar
	if health_bar:
		health_bar.min_value = 0
		health_bar.max_value = max_health
		health_bar.value = current_health

func set_visual_variant(index: int) -> void:
	texture_variant_index = wrapi(index, 0, VARIANT_TEXTURES.size())
	_apply_visual_variant()

func set_wave_theme(wave_index: int) -> void:
	var clamped_index: int = int(clamp(wave_index - 1, 0, WAVE_THEMES.size() - 1))
	theme_color = WAVE_THEMES[clamped_index]
	if visual_node:
		visual_node.modulate = theme_color
	set_visual_variant(clamped_index)

func set_difficulty(health_mult: float, speed_mult: float, reward_mult: float = 1.0) -> void:
	max_health = 80.0 * health_mult
	current_health = max_health
	move_speed = 90.0 * speed_mult
	money_reward = int(round(15.0 * reward_mult))
	score_reward = int(round(10.0 * reward_mult))
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

func _apply_visual_variant() -> void:
	if not visual_node:
		return
	var texture_path: String = VARIANT_TEXTURES[texture_variant_index]
	var texture: Texture2D = ResourceLoader.load(texture_path) as Texture2D
	if texture:
		visual_node.texture = texture

func setup_path(path: Path2D):
	"""Setup path following for this enemy"""
	path_to_follow = path
	
	if path_to_follow:
		# Create PathFollow2D for smooth movement
		path_follow = PathFollow2D.new()
		path_to_follow.add_child(path_follow)
		path_follow.progress = 0.0
		
		# Position at start of path
		global_position = path_follow.global_position
		print("📍 Enemy positioned at path start: ", global_position)

func _physics_process(delta):
	if is_dying or not is_moving:
		return
	
	_move_along_path(delta)

func _move_along_path(delta):
	"""Move enemy along the path"""
	if not path_follow or not path_to_follow:
		# Fallback movement if no path
		velocity = Vector2(move_speed, 0) * delta * 60
		move_and_slide()
		return
	
	# Move along path
	progress_on_path += move_speed * delta
	path_follow.progress = progress_on_path
	
	# Update position
	global_position = path_follow.global_position
	if visual_node:
		# Bobbing slower and with more amplitude for weight
		visual_node.position.y = -2 + sin(Time.get_ticks_msec() * 0.001) * 4.0
		# Subtle slow rotation to add life
		visual_node.rotation = sin(Time.get_ticks_msec() * 0.0008) * 0.04
	
	# Check if reached end
	if path_follow.progress_ratio >= 1.0:
		_reach_end()

func _reach_end():
	"""Handle reaching end of path"""
	print("💔 Enemy reached end!")
	enemy_reached_end.emit(damage_to_base)
	queue_free()

func take_damage(damage: float):
	"""Take damage and handle death"""
	if is_dying:
		return
	
	current_health -= damage
	_update_health_bar()
	
	if visual_node:
		visual_node.modulate = Color(1.0, 0.45, 0.45, 1.0)
		var tween = create_tween()
		# Quick squash and return to give feedback
		var orig_scale = visual_node.scale
		visual_node.scale = orig_scale * Vector2(1.05, 0.9)
		tween.tween_property(visual_node, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)
		tween.tween_property(visual_node, "scale", orig_scale, 0.18)
	
	# Flash effect
	modulate = Color.RED
	get_tree().create_timer(0.1).timeout.connect(func(): modulate = Color.WHITE)
	
	if current_health <= 0:
		_die()

func _die():
	"""Handle enemy death"""
	is_dying = true
	is_moving = false
	
	print("💀 Plastic waste destroyed!")
	
	# Emit death signal
	enemy_died.emit(enemy_type, money_reward, score_reward)
	
	# Death effect: pop and crumble with rotation
	modulate = Color.YELLOW
	if visual_node:
		var tween = create_tween()
		# pop outward then squash vertically and fade
		tween.tween_property(visual_node, "scale", Vector2(1.8, 0.5), 0.18)
		tween.parallel().tween_property(visual_node, "rotation", 0.6, 0.25)
		tween.parallel().tween_property(visual_node, "modulate:a", 0.0, 0.25)
		tween.tween_callback(queue_free)
	else:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
		tween.tween_callback(queue_free)

func _update_health_bar():
	"""Update health bar display"""
	if health_bar:
		health_bar.value = current_health
