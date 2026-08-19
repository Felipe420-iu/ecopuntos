extends CharacterBody2D
class_name BasicTower

# ===================================
# EcoPuntos Tower Defense - Basic Tower
# ===================================

signal projectile_fired(projectile)

## 🏗️ Tower Properties
@export var tower_type: Constants.TowerType = Constants.TowerType.PLASTIC
@export var fire_rate: float = 1.0  # Shots per second
@export var damage: float = 25.0
@export var range: float = 120.0
@export var projectile_speed: float = 360.0

const LEVELS := [
	{"damage": 25.0, "fire_rate": 1.0, "range": 120.0, "projectile_speed": 360.0},
	{"damage": 35.0, "fire_rate": 1.25, "range": 130.0, "projectile_speed": 420.0},
	{"damage": 48.0, "fire_rate": 1.45, "range": 145.0, "projectile_speed": 470.0},
	{"damage": 65.0, "fire_rate": 1.7, "range": 160.0, "projectile_speed": 520.0},
]
const BODY_TEXTURES := [
	"res://assets/desert_pack/towers/torrenivel1.png",
	"res://assets/desert_pack/towers/torrenivel2.png",
	"res://assets/desert_pack/towers/torrenivel3.png",
	"res://assets/desert_pack/towers/torrenivel4.png",
]
const CANNON_TEXTURES := [
	"res://assets/desert_pack/towers/cannon_tube_lvl1.png",
	"res://assets/desert_pack/towers/cannon_tube_lvl2.png",
	"res://assets/desert_pack/towers/cannon_tube_lvl3.png",
	"res://assets/desert_pack/towers/cannon_tube_lvl4.png",
]
const CANNON_TIP_OFFSETS := [42.0, 44.0, 46.0, 48.0]
const UPGRADE_COSTS := [0, 80, 120, 180]

var level: int = 1
var max_level: int = 4

## 🎯 Targeting
var target_enemy: CharacterBody2D = null
var enemies_in_range: Array[CharacterBody2D] = []
var fire_timer: Timer
var detection_area: Area2D
var detection_collision: CollisionShape2D
var muzzle_texture: Texture2D = preload("res://assets/desert_pack/bullets/balas.png")
var _base_cannon_position: Vector2 = Vector2.ZERO
var _base_cannon_sprite_position: Vector2 = Vector2.ZERO
var _base_cannon_sprite_rotation: float = 0.0
var _base_visual_position: Vector2 = Vector2.ZERO
var _base_muzzle_position: Vector2 = Vector2.ZERO

## 🎨 Visual Components
@onready var range_indicator: Node2D = $RangeIndicator if has_node("RangeIndicator") else null
@onready var cannon: Node2D = $Cannon if has_node("Cannon") else null
@onready var visual: Sprite2D = $Visual if has_node("Visual") else null
@onready var cannon_sprite: Sprite2D = $Cannon/CannonSprite if has_node("Cannon/CannonSprite") else null
@onready var muzzle_point: Marker2D = $Cannon/MuzzlePoint if has_node("Cannon/MuzzlePoint") else null

func _ready():
	print("🏗️ Basic Tower placed")
	add_to_group("towers")
	
	# Setup fire timer
	_setup_fire_timer()
	
	# Setup detection area
	_setup_detection_area()
	
	# Setup visuals
	_setup_visuals()
	_cache_base_positions()

	_apply_level(level)

func _process(_delta: float) -> void:
	_animate_idle_tube_motion()

func _setup_fire_timer():
	"""Setup automatic firing timer"""
	fire_timer = Timer.new()
	fire_timer.wait_time = 1.0 / fire_rate
	fire_timer.timeout.connect(_try_fire)
	add_child(fire_timer)
	fire_timer.start()

func _setup_detection_area():
	"""Setup area to detect enemies"""
	detection_area = Area2D.new()
	detection_area.collision_layer = 0
	detection_area.collision_mask = 1 << 1  # detect only enemies layer
	detection_area.monitoring = true
	detection_area.monitorable = true
	detection_collision = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = range
	detection_collision.shape = circle_shape
	detection_area.add_child(detection_collision)
	add_child(detection_area)

	# Connect area signals
	detection_area.body_entered.connect(_on_enemy_entered_range)
	detection_area.body_exited.connect(_on_enemy_exited_range)

func _setup_visuals():
	"""Setup tower visual appearance"""
	# This will be handled by the Visual node if it exists
	pass

func _cache_base_positions() -> void:
	if cannon:
		_base_cannon_position = cannon.position
	if cannon_sprite:
		_base_cannon_sprite_position = cannon_sprite.position
		_base_cannon_sprite_rotation = cannon_sprite.rotation
	if visual:
		_base_visual_position = visual.position
	if muzzle_point:
		_base_muzzle_position = muzzle_point.position

func _animate_idle_tube_motion() -> void:
	var time := Time.get_ticks_msec() * 0.001
	if cannon_sprite:
		cannon_sprite.position = _base_cannon_sprite_position + Vector2(0.0, sin(time * 4.0) * 1.8)
		cannon_sprite.rotation = _base_cannon_sprite_rotation + sin(time * 3.0) * 0.06
	if visual:
		visual.position = _base_visual_position + Vector2(0.0, sin(time * 2.0) * 0.4)
	if muzzle_point:
		muzzle_point.position = _base_muzzle_position + Vector2(0.0, sin(time * 4.0) * 0.4)

func _apply_level(new_level: int):
	level = clamp(new_level, 1, max_level)
	var data = LEVELS[level - 1]
	damage = data["damage"]
	fire_rate = data["fire_rate"]
	range = data["range"]
	projectile_speed = data["projectile_speed"]
	if fire_timer:
		fire_timer.wait_time = 1.0 / fire_rate
	if detection_collision and detection_collision.shape is CircleShape2D:
		(detection_collision.shape as CircleShape2D).radius = range
	if range_indicator:
		range_indicator.scale = Vector2.ONE * (range / 120.0)
	if visual:
		var tex_path = BODY_TEXTURES[level - 1] if level - 1 < BODY_TEXTURES.size() else ""
		if tex_path != "":
			var tex = load(tex_path)
			if tex:
				visual.texture = tex
	if cannon_sprite:
		var cannon_tex_path = CANNON_TEXTURES[level - 1] if level - 1 < CANNON_TEXTURES.size() else ""
		if cannon_tex_path != "":
			var cannon_tex = load(cannon_tex_path)
			if cannon_tex:
				cannon_sprite.texture = cannon_tex
				cannon_sprite.scale = Vector2.ONE * (0.82 + (level - 1) * 0.08)
				cannon_sprite.position = _base_cannon_sprite_position + Vector2(0.0, -3.0 * (level - 1))
	if muzzle_point:
		muzzle_point.position = _base_muzzle_position + Vector2(0.0, -2.0 * (level - 1))
	print("📈 Torre nivel ", level, " => daño ", damage, " cadencia ", fire_rate, " rango ", range)

func _try_fire():
	"""Try to fire at target enemy"""
	_update_target()
	
	if target_enemy and is_instance_valid(target_enemy):
		_fire_at_target()

func _update_target():
	"""Update current target enemy"""
	# Remove invalid enemies from list
	enemies_in_range = enemies_in_range.filter(func(enemy): return is_instance_valid(enemy))
	
	if enemies_in_range.is_empty():
		target_enemy = null
		return
	
	# Target closest enemy to end of path
	# For simplicity, target first enemy in range
	target_enemy = enemies_in_range[0]

func _fire_at_target():
	"""Fire projectile at current target"""
	if not target_enemy:
		return
	
	print("💥 Tower firing at enemy!")
	
	# Calculate direction to target
	var spawn_pos = _get_cannon_tip_position()
	var direction = (target_enemy.global_position - spawn_pos).normalized()

	# Orientar el cañón hacia el enemigo (incluye arriba/abajo). Node2D.look_at apunta su eje +X, por eso compensamos 90° si el sprite apunta hacia arriba.
	if cannon:
		cannon.look_at(target_enemy.global_position)
		cannon.rotation -= PI * 0.5
	
	# Rotate cannon if it exists
	if cannon:
		var recoil_tween := create_tween()
		var cannon_start_scale: Vector2 = cannon.scale
		recoil_tween.tween_property(cannon, "scale", cannon_start_scale * Vector2(0.96, 1.04), 0.05)
		recoil_tween.tween_property(cannon, "scale", cannon_start_scale, 0.08)
	if cannon_sprite:
		var cannon_sprite_tween := create_tween()
		cannon_sprite_tween.tween_property(cannon_sprite, "position:y", _base_cannon_sprite_position.y + 5.0, 0.04)
		cannon_sprite_tween.tween_property(cannon_sprite, "position:y", _base_cannon_sprite_position.y, 0.09)
		cannon_sprite_tween.parallel().tween_property(cannon_sprite, "rotation", _base_cannon_sprite_rotation - 0.12, 0.04)
		cannon_sprite_tween.tween_property(cannon_sprite, "rotation", _base_cannon_sprite_rotation, 0.09)
	
	# Create simple projectile
	_create_projectile(direction, spawn_pos)
	_spawn_muzzle_flash(spawn_pos, direction)

func _create_projectile(direction: Vector2, spawn_pos: Vector2):
	"""Create and fire projectile"""
	var projectile = preload("res://scenes/gameplay/BasicProjectile.tscn").instantiate()
	
	# Setup projectile
	projectile.global_position = spawn_pos
	projectile.direction = direction
	projectile.speed = projectile_speed
	projectile.damage = damage
	projectile.target_enemy = target_enemy
	projectile.is_homing = true
	projectile.collision_layer = 0
	projectile.collision_mask = 1 << 1  # hit enemies
	
	# Add to projectiles container
	var game_world = get_tree().get_first_node_in_group("game_world")
	if game_world:
		var projectiles_container = game_world.get_node("Projectiles")
		projectiles_container.add_child(projectile)
		projectile_fired.emit(projectile)

func _on_enemy_entered_range(body):
	"""Handle enemy entering range"""
	if body.has_method("take_damage"):  # Check if it's an enemy
		enemies_in_range.append(body)
		print("🎯 Enemy entered tower range")

func _on_enemy_exited_range(body):
	"""Handle enemy exiting range"""
	if body in enemies_in_range:
		enemies_in_range.erase(body)
		if target_enemy == body:
			target_enemy = null
		print("📤 Enemy exited tower range")

func _get_cannon_tip_position() -> Vector2:
	"""Compute a spawn point at the tip of the cannon sprite"""
	if muzzle_point:
		return muzzle_point.global_position
	if cannon_sprite and cannon_sprite.texture:
		var cannon_tip_offset: float = CANNON_TIP_OFFSETS[level - 1] if level - 1 < CANNON_TIP_OFFSETS.size() else 42.0
		var tip_local = cannon_sprite.position + Vector2(0.0, -cannon_tip_offset * cannon_sprite.scale.y)
		return cannon_sprite.to_global(tip_local)
	return cannon.global_position if cannon else global_position

func _spawn_muzzle_flash(spawn_pos: Vector2, direction: Vector2):
	"""Spawn a brief muzzle flash at the cannon tip"""
	var flash := CPUParticles2D.new()
	flash.one_shot = true
	flash.lifetime = 0.15
	flash.amount = 12
	flash.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	flash.direction = direction.normalized()
	flash.spread = 0.6
	flash.initial_velocity_min = 120.0
	flash.initial_velocity_max = 200.0
	flash.scale_amount_min = 0.2
	flash.scale_amount_max = 0.6
	flash.gravity = Vector2.ZERO
	flash.color = Color(1, 0.7, 0.2, 0.9)
	if muzzle_texture:
		flash.texture = muzzle_texture
	flash.global_position = spawn_pos
	get_tree().current_scene.add_child(flash)
	flash.emitting = true

func upgrade() -> bool:
	"""Upgrade tower stats if possible"""
	if level >= max_level:
		return false
	_apply_level(level + 1)
	return true

func get_upgrade_cost() -> int:
	return UPGRADE_COSTS[level] if level < max_level else 0

func _draw():
	"""Debug drawing for range indicator"""
	var vp := get_viewport()
	if vp and vp.has_method("get_debug_draw") and vp.get_debug_draw() != Viewport.DEBUG_DRAW_DISABLED:
		draw_circle(Vector2.ZERO, range, Color(0, 1, 0, 0.1))
		draw_arc(Vector2.ZERO, range, 0, TAU, 64, Color(0, 1, 0, 0.5), 2.0)
