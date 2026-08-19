extends Control

func _ready():
	print("🚀 EcoPuntos Tower Defense - Main Menu Loaded")
	print("GameManager available: ", GameManager != null)
	print("Constants available: ", Constants != null)
	print("Press ENTER to start game, ESC to quit")

func _input(event):
	if event.is_action_pressed("ui_accept"):  # ENTER
		print("🎮 Starting Game World...")
		get_tree().change_scene_to_file("res://GameWorld.tscn")
	
	if event.is_action_pressed("ui_cancel"):  # ESC
		print("👋 Goodbye!")
		get_tree().quit()
