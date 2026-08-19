extends Area2D
class_name Tower

# Tower progression data
const MAX_LEVEL := 4
const LEVELS := {
	1: {"texture": "res://assets/desert_pack/towers/torrenivel1.png", "damage": 20, "fire_rate": 1.0, "projectile_level": 1, "upgrade_cost": 80},
	2: {"texture": "res://assets/desert_pack/towers/torrenivel2.png", "damage": 30, "fire_rate": 1.2, "projectile_level": 2, "upgrade_cost": 120},
	3: {"texture": "res://assets/desert_pack/towers/torrenivel3.png", "damage": 45, "fire_rate": 1.4, "projectile_level": 3, "upgrade_cost": 180},
	4: {"texture": "res://assets/desert_pack/towers/torrenivel4.png", "damage": 65, "fire_rate": 1.6, "projectile_level": 4, "upgrade_cost": 0},
}

@export var range_pixels: float = 140.0
var current_level: int = 1
var money_manager: Node = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var range_area: Area2D = $RangeArea
@onready var fire_timer: Timer = $FireTimer

var enemies_in_range: Array[Node2D] = []

func _ready():
	add_to_group("towers")
	money_manager = get_tree().get_first_node_in_group("game_state")
	_setup_range_area()
	_apply_level(current_level)
	if fire_timer:
		fire_timer.timeout.connect(_try_fire)
		_fire_timer_update()

func _setup_range_area():
	if not range_area:
		return
	range_area.collision_layer = 0
	range_area.collision_mask = 1 << 1  # enemies on layer 2
	var shape := CircleShape2D.new()
	shape.radius = range_pixels
	var collider := range_area.get_node("CollisionShape2D") as CollisionShape2D
	collider.shape = shape
	range_area.body_entered.connect(_on_body_entered)
	range_area.body_exited.connect(_on_body_exited)

func _apply_level(level: int):
	var data = LEVELS[level]
	sprite.texture = _load_texture_or_placeholder(data["texture"], Color(0.2, 0.7, 0.4))
	_fire_timer_update()

func _load_texture_or_placeholder(path: String, color: Color) -> Texture2D:
	var tex = ResourceLoader.load(path) as Texture2D
	if tex:
		return tex
	# Generate a tiny placeholder texture
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(color)
	var itex := ImageTexture.create_from_image(img)
	return itex

func _fire_timer_update():
	var data = LEVELS[current_level]
	fire_timer.wait_time = 1.0 / data["fire_rate"]
	fire_timer.start()

func _try_fire():
	_cleanup_enemies()
	if enemies_in_range.is_empty():
		_fire_timer_update()
		return
	var target: Node2D = enemies_in_range[0]
	if not is_instance_valid(target):
		_fire_timer_update()
		return
	_fire_at_target(target)
	_fire_timer_update()

func _fire_at_target(target: Node2D):
	var data = LEVELS[current_level]
	var projectile_scene = load("res://progression/scenes/Projectile.tscn")
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.setup(data["projectile_level"], target, data["damage"])
	projectile.collision_layer = 1 << 2  # projectiles on layer 3
	projectile.collision_mask = 1 << 1  # collide with enemies
	var main = get_tree().get_first_node_in_group("main_root")
	if main:
		main.add_child(projectile)

func upgrade_tower():
	if current_level >= MAX_LEVEL:
		return false
	var next_level = current_level + 1
	var cost = LEVELS[next_level]["upgrade_cost"]
	if money_manager and money_manager.has_method("try_spend"):
		if not money_manager.try_spend(cost):
			return false
	current_level = next_level
	_apply_level(current_level)
	return true

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		enemies_in_range.append(body)
		enemies_in_range.sort_custom(func(a, b): return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position))

func _on_body_exited(body):
	if body in enemies_in_range:
		enemies_in_range.erase(body)

func _cleanup_enemies():
	enemies_in_range = enemies_in_range.filter(func(e): return e and is_instance_valid(e) and e.is_in_group("enemies"))
