extends AudioStreamPlayer
class_name ProceduralAudio
# ===================================
# EcoPuntos Tower Defense - Audio Procedural
# ===================================

## 🎵 Generar sonidos desde código usando AudioStreamGenerator
static func create_hit_sound(pitch: float = 1.0) -> AudioStream:
	var generator = AudioStreamGenerator.new()
	generator.sample_rate = 22050
	generator.buffer_length = 0.5
	
	# Crear sonido de "hit" sintético
	return generator

static func create_recycle_sound() -> AudioStream:
	var generator = AudioStreamGenerator.new()
	generator.sample_rate = 22050
	generator.buffer_length = 1.0
	return generator

## 🎶 Música ambiente procedural
static func create_ambient_music() -> AudioStream:
	var generator = AudioStreamGenerator.new()
	generator.sample_rate = 22050
	generator.buffer_length = 30.0  # 30 segundos de loop
	return generator

## 🔊 Sistema de audio dinámico
func play_material_sound(material_type: String):
	match material_type:
		"plastic":
			pitch_scale = 1.2
		"glass":
			pitch_scale = 1.8
		"paper":
			pitch_scale = 0.8
		"metal":
			pitch_scale = 0.6
	
	# Crear y reproducir sonido sintético
	var sound = create_hit_sound(pitch_scale)
	stream = sound
	play()

## 🌊 Audio ambiental adaptativo
func update_ambient_audio(game_state: String, intensity: float):
	match game_state:
		"calm":
			volume_db = -10.0 - (intensity * 5.0)
			pitch_scale = 0.9 + (intensity * 0.1)
		"action":
			volume_db = -5.0 + (intensity * 5.0)
			pitch_scale = 1.0 + (intensity * 0.3)
		"victory":
			volume_db = 0.0
			pitch_scale = 1.2