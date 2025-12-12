extends Control

func _ready():
	print("Main scene loaded successfully!")
	print("GameManager active: ", GameManager)
	print("Constants loaded: ", Constants)
	
	# Test GameManager initialization
	if GameManager:
		print("✅ GameManager autoload working")
		print("Game State: ", GameManager.get_game_state())
		print("Starting coins: ", GameManager.get_coins())
	else:
		print("❌ GameManager autoload failed")
	
	# Test Constants
	if Constants:
		print("✅ Constants autoload working")
		print("Base tower cost: ", Constants.BASE_TOWER_COST)
		print("API URL: ", Constants.ECOPUNTOS_API_URL)
	else:
		print("❌ Constants autoload failed")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

	# DEBUG: auto-start the game for testing so scenes and enemies appear
	# Wait a short moment to allow autoloads to initialize
	await get_tree().create_timer(0.2).timeout
	if GameManager and Constants:
		# Change to PLAYING state and start level 1 (if available)
		GameManager.change_game_state(Constants.GameState.PLAYING)
		if GameManager.level_manager:
			GameManager.level_manager.start_level(1)
