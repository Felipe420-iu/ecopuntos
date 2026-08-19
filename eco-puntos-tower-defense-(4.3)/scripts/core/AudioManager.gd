extends Node
class_name AudioManager
# ===================================
# EcoPuntos Tower Defense - Audio Manager
# ===================================

func _ready():
	print("🎵 AudioManager initialized successfully")

	# Create a dedicated music player
	if not has_node("MusicPlayer"):
		var mp = AudioStreamPlayer.new()
		mp.name = "MusicPlayer"
		mp.bus = "Music" if Engine.has_singleton("AudioServer") else "Master"
		add_child(mp)

	# Container for one-shot SFX players
	if not has_node("SFX"):
		var sfx_holder = Node.new()
		sfx_holder.name = "SFX"
		add_child(sfx_holder)

func play_background_music(track_name: String) -> void:
	"""Play background music. If an audio file exists in `res://audio/<track_name>.ogg` it will be used.
	If not, play procedural ambient music as fallback."""
	var music_player: AudioStreamPlayer = get_node("MusicPlayer")
	var path = "res://audio/" + track_name + ".ogg"
	if ResourceLoader.exists(path):
		var stream = ResourceLoader.load(path)
		music_player.stream = stream
		music_player.play()
		return
	# Fallback procedural
	if Engine.has_singleton("ProceduralAudio"):
		# If ProceduralAudio class exists, create ambient stream
		var pa = ProceduralAudio.new()
		pa.stream = ProceduralAudio.create_ambient_music()
		music_player.stream = pa.stream
		music_player.play()
		return
	# Otherwise no-op
	print("🎵 [AudioManager] track not found, skipping: ", track_name)

func play_sfx(sfx_name: String) -> void:
	"""Play a short sfx. Looks for `res://audio/<sfx_name>.ogg` otherwise uses procedural sounds."""
	var holder = get_node("SFX")
	var path = "res://audio/" + sfx_name + ".ogg"
	var player = AudioStreamPlayer.new()
	player.bus = "SFX" if Engine.has_singleton("AudioServer") else "Master"
	holder.add_child(player)
	if ResourceLoader.exists(path):
		player.stream = ResourceLoader.load(path)
		player.play()
		# Queue free after finished
		player.connect("finished", Callable(player, "queue_free"))
		return
	# Fallback procedural mapping
	match sfx_name:
		"game_over":
			player.stream = ProceduralAudio.create_hit_sound()
			player.play()
		"victory":
			player.stream = ProceduralAudio.create_ambient_music()
			player.play()
		"life_lost":
			player.stream = ProceduralAudio.create_hit_sound()
			player.play()
		"wave_complete":
			player.stream = ProceduralAudio.create_recycle_sound()
			player.play()
		_:
			player.stream = ProceduralAudio.create_hit_sound()
			player.play()

func stop_background_music():
	var music_player = get_node_or_null("MusicPlayer")
	if music_player:
		music_player.stop()

func play_tower_fire_sfx(tower_type):
	"""Convenience wrapper to play a tower-specific firing sfx."""
	var name = "tower_fire"
	match int(tower_type):
		Constants.TowerType.PLASTIC:
			name = "plastic_fire"
		Constants.TowerType.GLASS:
			name = "glass_fire"
		Constants.TowerType.PAPER:
			name = "paper_fire"
		Constants.TowerType.METAL:
			name = "metal_fire"
	play_sfx(name)
