extends Node2D
class_name ProceduralArt
# ===================================
# EcoPuntos Tower Defense - Arte Procedural
# ===================================

## 🎨 Generar sprites desde código
static func create_plastic_bottle_sprite() -> Texture2D:
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	
	# Dibujar botella de plástico
	for y in range(64):
		for x in range(64):
			var color = Color.TRANSPARENT
			
			# Forma de botella
			var center_x = 32
			var center_y = 32
			var distance = Vector2(x - center_x, y - center_y).length()
			
			if distance < 20:  # Cuerpo de la botella
				if y < 40:  # Parte superior más estrecha
					if distance < 15:
						color = Color(0.9, 0.9, 0.3, 0.8)  # Amarillo plástico
				else:  # Parte inferior
					if distance < 20:
						color = Color(0.9, 0.9, 0.3, 0.8)
			
			# Tapa
			if y < 20 and distance < 10:
				color = Color(0.2, 0.8, 0.2, 1.0)  # Verde tapa
			
			image.set_pixel(x, y, color)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

static func create_tower_sprite(tower_type: String) -> Texture2D:
	var image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	var base_color: Color
	
	match tower_type:
		"plastic_recycler":
			base_color = Color.YELLOW
		"glass_crusher":
			base_color = Color.CYAN
		"paper_shredder":
			base_color = Color.BROWN
		"metal_magnet":
			base_color = Color.GRAY
		_:
			base_color = Color.WHITE
	
	# Dibujar torre cuadrada con gradiente
	for y in range(48):
		for x in range(48):
			var distance_from_center = Vector2(x - 24, y - 24).length()
			if distance_from_center < 20:
				var intensity = 1.0 - (distance_from_center / 20.0) * 0.3
				var color = base_color * intensity
				color.a = 1.0
				image.set_pixel(x, y, color)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

## 🌟 Crear efectos de partículas desde código
static func create_hit_effect(parent: Node2D, position: Vector2, material_type: String):
	var particles = GPUParticles2D.new()
	parent.add_child(particles)
	particles.global_position = position
	
	# Configurar material de partículas
	var material = ParticleProcessMaterial.new()
	
	match material_type:
		"plastic":
			material.color = Color.YELLOW
			material.scale_min = 0.5
			material.scale_max = 1.5
		"glass":
			material.color = Color.CYAN
			material.scale_min = 0.2
			material.scale_max = 0.8
		"paper":
			material.color = Color.BROWN
			material.scale_min = 1.0
			material.scale_max = 2.0
	
	material.direction = Vector3(0, -1, 0)
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 100.0
	material.gravity = Vector3(0, 98, 0)
	material.scale_random = 0.5
	
	particles.process_material = material
	particles.amount = 20
	particles.lifetime = 2.0
	particles.emitting = true
	
	# Auto-destruir después de la animación
	var timer = Timer.new()
	parent.add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(func(): particles.queue_free(); timer.queue_free())
	timer.start()