extends CharacterBody2D
class_name PlasticWaste

# ===================================
# EcoPuntos Tower Defense - Plastic Waste Enemy  
# ===================================

signal enemy_died(enemy_type: Constants.EnemyType, money_reward: int, score_reward: int)
signal enemy_reached_end

## 🏷️ Enemy Properties
var enemy_type: Constants.EnemyType = Constants.EnemyType.PLASTIC_WASTE
var max_health: float = 80.0
var current_health: float
var move_speed: float = 90.0
var money_reward: int = 15
var score_reward: int = 10
var damage_to_base: int = 1

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
		# Visual node will handle drawing
		pass
	
	# Setup health bar
	if health_bar:
		health_bar.min_value = 0
		health_bar.max_value = max_health
		health_bar.value = current_health

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
	
	# Check if reached end
	if path_follow.progress_ratio >= 1.0:
		_reach_end()

func _reach_end():
	"""Handle reaching end of path"""
	print("💔 Enemy reached end!")
	enemy_reached_end.emit()
	queue_free()

func take_damage(damage: float):
	"""Take damage and handle death"""
	if is_dying:
		return
	
	current_health -= damage
	_update_health_bar()
	
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
	
	# Death effect
	modulate = Color.YELLOW
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

func _update_health_bar():
	"""Update health bar display"""
	if health_bar:
		health_bar.value = current_health
