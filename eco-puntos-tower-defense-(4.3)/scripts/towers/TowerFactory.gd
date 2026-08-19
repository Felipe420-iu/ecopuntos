extends Node
class_name TowerFactory
# ===================================
# EcoPuntos Tower Defense - Fábrica de Torres Procedural
# ===================================

## 🏗️ Definiciones de torres desde código
static var tower_definitions = {
	"basic_recycler": {
		"name": "Reciclador Básico",
		"damage": 10,
		"range": 100,
		"fire_rate": 1.0,
		"cost": 50,
		"description": "Torre básica que recicla cualquier material",
		"sprite_color": Color.GRAY,
		"projectile_type": "energy_bolt"
	},
	"plastic_melter": {
		"name": "Derretidor de Plástico",
		"damage": 15,
		"range": 80,
		"fire_rate": 0.8,
		"cost": 75,
		"description": "Especialista en derreter botellas plásticas",
		"sprite_color": Color.YELLOW,
		"projectile_type": "heat_ray",
		"bonus_vs": ["plastic"]
	},
	"glass_crusher": {
		"name": "Triturador de Vidrio",
		"damage": 20,
		"range": 60,
		"fire_rate": 1.2,
		"cost": 100,
		"description": "Tritura vidrio con ondas sónicas",
		"sprite_color": Color.CYAN,
		"projectile_type": "sonic_wave",
		"bonus_vs": ["glass"],
		"area_damage": 30
	},
	"paper_shredder": {
		"name": "Trituradora de Papel",
		"damage": 8,
		"range": 120,
		"fire_rate": 2.0,
		"cost": 60,
		"description": "Dispara múltiples proyectiles de papel",
		"sprite_color": Color.BROWN,
		"projectile_type": "paper_storm",
		"bonus_vs": ["paper"],
		"multi_shot": 3
	},
	"metal_magnet": {
		"name": "Imán de Metal",
		"damage": 25,
		"range": 90,
		"fire_rate": 0.6,
		"cost": 150,
		"description": "Atrae y destruye metales",
		"sprite_color": Color.DARK_GRAY,
		"projectile_type": "magnetic_pulse",
		"bonus_vs": ["metal"],
		"pulls_enemies": true
	},
	# TORRES AVANZADAS
	"super_recycler": {
		"name": "Super Reciclador",
		"damage": 30,
		"range": 150,
		"fire_rate": 0.5,
		"cost": 300,
		"description": "Torre definitiva que recicla todo",
		"sprite_color": Color.RAINBOW,
		"projectile_type": "rainbow_beam",
		"bonus_vs": ["plastic", "glass", "paper", "metal"],
		"generates_coins": 5
	},
	"eco_laser": {
		"name": "Láser Ecológico",
		"damage": 50,
		"range": 200,
		"fire_rate": 0.3,
		"cost": 500,
		"description": "Láser solar de alta potencia",
		"sprite_color": Color.GREEN,
		"projectile_type": "solar_laser",
		"pierces_enemies": 3,
		"eco_friendly": true
	}
}

## 🏗️ Crear torre dinámicamente desde código
static func create_tower(tower_type: String, position: Vector2) -> Node2D:
	var tower_data = tower_definitions.get(tower_type, {})
	if tower_data.is_empty():
		print("❌ Torre tipo '", tower_type, "' no encontrada")
		return null
	
	# Crear nodo de torre
	var tower = CharacterBody2D.new()
	tower.name = tower_data.get("name", "Torre")
	tower.position = position
	
	# Añadir sprite procedural
	var sprite = Sprite2D.new()
	sprite.texture = ProceduralArt.create_tower_sprite(tower_type)
	sprite.modulate = tower_data.get("sprite_color", Color.WHITE)
	tower.add_child(sprite)
	
	# Añadir área de ataque
	var attack_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = tower_data.get("range", 100)
	collision_shape.shape = circle_shape
	attack_area.add_child(collision_shape)
	tower.add_child(attack_area)
	
	# Añadir script de comportamiento
	var tower_script = create_tower_script(tower_data)
	tower.set_script(tower_script)
	
	return tower

## 📜 Crear script de torre dinámicamente
static func create_tower_script(tower_data: Dictionary) -> GDScript:
	var script_code = """
extends CharacterBody2D

var damage = %d
var fire_rate = %.2f
var range = %d
var last_shot_time = 0.0

func _ready():
	print("🏗️ Torre '%s' creada")

func _process(_delta):
	var now_seconds = OS.get_ticks_msec() / 1000.0
	if now_seconds - last_shot_time > (1.0 / fire_rate):
		_try_shoot()

func _try_shoot():
	# Buscar enemigos en rango
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) <= range:
			_shoot_at(enemy)
			last_shot_time = OS.get_ticks_msec() / 1000.0
			break

func _shoot_at(target):
	print("💥 Torre disparando a enemigo")
	# Crear proyectil
	target.take_damage(damage)
""" % [
		tower_data.get("damage", 10),
		tower_data.get("fire_rate", 1.0),
		tower_data.get("range", 100),
		tower_data.get("name", "Torre")
	]
	
	var script = GDScript.new()
	script.source_code = script_code
	return script