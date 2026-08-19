extends Control
class_name HUD

# ===================================
# EcoPuntos Tower Defense - Game HUD
# ===================================

signal tower_selected_for_placement(tower_type: Constants.TowerType)
signal pause_requested()
signal menu_requested()

# 📊 Resource Display
@onready var money_label: Label = $TopBar/MoneyContainer/MoneyLabel
@onready var lives_label: Label = $TopBar/LivesContainer/LivesLabel
@onready var score_label: Label = $TopBar/ScoreContainer/ScoreLabel
@onready var wave_label: Label = $TopBar/WaveContainer/WaveLabel

# 🏗️ Tower Shop
@onready var tower_shop: Control = $TowerShop
@onready var plastic_tower_button: Button = $TowerShop/VBoxContainer/PlasticTowerButton
@onready var glass_tower_button: Button = $TowerShop/VBoxContainer/GlassTowerButton
@onready var paper_tower_button: Button = $TowerShop/VBoxContainer/PaperTowerButton
@onready var metal_tower_button: Button = $TowerShop/VBoxContainer/MetalTowerButton

# ⏯️ Control Buttons
@onready var pause_button: Button = $TopBar/ControlButtons/PauseButton
@onready var menu_button: Button = $TopBar/ControlButtons/MenuButton
@onready var speed_button: Button = $TopBar/ControlButtons/SpeedButton

# 📈 Progress Bars
@onready var wave_progress: ProgressBar = $WaveProgress
@onready var health_bar: ProgressBar = $BaseHealth

# 🎮 Game State
var current_money: int = 0
var current_lives: int = 0
var current_score: int = 0
var current_wave: int = 1
var total_waves: int = 10
var game_speed: float = 1.0

# 🔗 References
var game_manager: GameManager
var tower_manager: TowerManager
var wave_manager: WaveManager

func _ready():
	# Setup UI
	_setup_ui()
	_connect_signals()
	_find_managers()
	
	# Initialize display
	_update_all_displays()
	
	print("🖥️ HUD initialized")

func _setup_ui():
	"""Setup UI components and styling"""
	# Apply EcoPuntos theme colors
	_apply_eco_theme()
	
	# Setup tower buttons with costs
	_setup_tower_buttons()
	
	# Setup progress bars
	if wave_progress:
		wave_progress.value = 0
		wave_progress.max_value = 100
	
	if health_bar:
		health_bar.value = 100
		health_bar.max_value = 100

func _apply_eco_theme():
	"""Apply EcoPuntos visual theme"""
	# Set background colors with transparency
	modulate = Color(1, 1, 1, 0.95)
	
	# Apply eco colors to key elements
	if money_label:
		money_label.add_theme_color_override("font_color", Constants.COLOR_ECO_GREEN)
	if score_label:
		score_label.add_theme_color_override("font_color", Constants.COLOR_ECO_BLUE)
	if lives_label:
		lives_label.add_theme_color_override("font_color", Constants.COLOR_DANGER_RED)

func _setup_tower_buttons():
	"""Setup tower shop buttons"""
	var tower_configs = [
		{"button": plastic_tower_button, "type": Constants.TowerType.PLASTIC, "cost": 60, "name": "Plastic\nRecycler"},
		{"button": glass_tower_button, "type": Constants.TowerType.GLASS, "cost": 80, "name": "Glass\nRecycler"},
		{"button": paper_tower_button, "type": Constants.TowerType.PAPER, "cost": 50, "name": "Paper\nRecycler"},
		{"button": metal_tower_button, "type": Constants.TowerType.METAL, "cost": 100, "name": "Metal\nRecycler"}
	]
	
	for config in tower_configs:
		var button = config["button"]
		if button:
			button.text = config["name"] + "\n$" + str(config["cost"])
			button.pressed.connect(_on_tower_button_pressed.bind(config["type"], config["cost"]))

func _connect_signals():
	"""Connect UI signals"""
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)
	if speed_button:
		speed_button.pressed.connect(_on_speed_pressed)

func _find_managers():
	"""Find manager references"""
	game_manager = get_tree().get_first_node_in_group("game_manager")
	tower_manager = get_tree().get_first_node_in_group("tower_manager")
	wave_manager = get_tree().get_first_node_in_group("wave_manager")
	
	# Connect to manager signals
	if game_manager:
		game_manager.money_changed.connect(_on_money_changed)
		game_manager.lives_changed.connect(_on_lives_changed)
		game_manager.score_changed.connect(_on_score_changed)
		game_manager.game_state_changed.connect(_on_game_state_changed)
	
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_completed.connect(_on_wave_completed)

# 📊 Display Updates
func _update_all_displays():
	"""Update all UI displays with current values"""
	_update_money_display()
	_update_lives_display()
	_update_score_display()
	_update_wave_display()

func _update_money_display():
	"""Update money display"""
	if money_label:
		money_label.text = "💰 $" + str(current_money)

func _update_lives_display():
	"""Update lives display"""
	if lives_label:
		lives_label.text = "❤️ " + str(current_lives)
	
	# Update health bar
	if health_bar and current_lives > 0:
		var health_percentage = float(current_lives) / float(Constants.STARTING_LIVES) * 100
		health_bar.value = health_percentage
		
		# Color coding
		if health_percentage > 70:
			health_bar.modulate = Constants.COLOR_ECO_GREEN
		elif health_percentage > 30:
			health_bar.modulate = Constants.COLOR_ECO_ORANGE
		else:
			health_bar.modulate = Constants.COLOR_DANGER_RED

func _update_score_display():
	"""Update score display"""
	if score_label:
		score_label.text = "🏆 " + str(current_score)

func _update_wave_display():
	"""Update wave display"""
	if wave_label:
		wave_label.text = "🌊 Wave " + str(current_wave) + "/" + str(total_waves)

func _update_wave_progress():
	"""Update wave progress bar"""
	if wave_progress and wave_manager:
		var progress = wave_manager.get_wave_progress() * 100
		wave_progress.value = progress

func _update_tower_button_states():
	"""Update tower button states based on affordability"""
	var tower_buttons = [
		{"button": plastic_tower_button, "cost": 60},
		{"button": glass_tower_button, "cost": 80},
		{"button": paper_tower_button, "cost": 50},
		{"button": metal_tower_button, "cost": 100}
	]
	
	for config in tower_buttons:
		var button = config["button"]
		var cost = config["cost"]
		
		if button:
			var can_afford = current_money >= cost
			button.disabled = not can_afford
			button.modulate = Color.WHITE if can_afford else Color(0.7, 0.7, 0.7, 1.0)

# 🏗️ Tower Placement
func _on_tower_button_pressed(tower_type: Constants.TowerType, cost: int):
	"""Handle tower button press"""
	if current_money >= cost:
		tower_selected_for_placement.emit(tower_type)
		_show_tower_placement_mode(tower_type)
	else:
		_show_insufficient_funds_message()

func _show_tower_placement_mode(tower_type: Constants.TowerType):
	"""Show visual feedback for tower placement mode"""
	# Change cursor or add visual indicators
	# This would be implemented with the actual tower placement system
	print("🏗️ Entering placement mode for ", tower_type)

func _show_insufficient_funds_message():
	"""Show message when player can't afford tower"""
	# Create temporary label for feedback
	var message = Label.new()
	message.text = "Insufficient Funds!"
	message.add_theme_color_override("font_color", Constants.COLOR_DANGER_RED)
	message.position = money_label.global_position + Vector2(0, 30)
	add_child(message)
	
	# Animate and remove message
	var tween = create_tween()
	tween.parallel().tween_property(message, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(message, "position:y", message.position.y - 20, 1.0)
	tween.tween_callback(message.queue_free)

# ⏯️ Game Controls
func _on_pause_pressed():
	"""Handle pause button press"""
	pause_requested.emit()
	print("⏸️ Pause requested from HUD")

func _on_menu_pressed():
	"""Handle menu button press"""
	menu_requested.emit()
	print("📱 Menu requested from HUD")

func _on_speed_pressed():
	"""Handle speed button press"""
	# Cycle through speed options
	match game_speed:
		1.0:
			game_speed = 1.5
			speed_button.text = "1.5x"
		1.5:
			game_speed = 2.0
			speed_button.text = "2x"
		2.0:
			game_speed = 1.0
			speed_button.text = "1x"
	
	# Apply speed to game
	Engine.time_scale = game_speed
	print("⚡ Game speed set to ", game_speed, "x")

# 📡 Signal Handlers
func _on_money_changed(new_amount: int):
	"""Handle money change"""
	current_money = new_amount
	_update_money_display()
	_update_tower_button_states()

func _on_lives_changed(new_amount: int):
	"""Handle lives change"""
	current_lives = new_amount
	_update_lives_display()

func _on_score_changed(new_score: int):
	"""Handle score change"""
	current_score = new_score
	_update_score_display()

func _on_wave_started(wave_number: int):
	"""Handle wave start"""
	current_wave = wave_number
	_update_wave_display()

func _on_wave_completed(wave_number: int):
	"""Handle wave completion"""
	_show_wave_complete_message(wave_number)

func _on_game_state_changed(new_state: Constants.GameState):
	"""Handle game state change"""
	match new_state:
		Constants.GameState.PLAYING:
			show()
			_enable_all_controls()
		Constants.GameState.PAUSED:
			_disable_game_controls()
		Constants.GameState.GAME_OVER, Constants.GameState.VICTORY:
			_disable_all_controls()
		Constants.GameState.MENU:
			hide()

func _enable_all_controls():
	"""Enable all UI controls"""
	if tower_shop:
		tower_shop.visible = true
	_update_tower_button_states()

func _disable_game_controls():
	"""Disable game-specific controls but keep menu controls"""
	_update_tower_button_states()  # This will disable based on affordability

func _disable_all_controls():
	"""Disable all controls"""
	if tower_shop:
		tower_shop.visible = false

# 💬 Feedback Messages
func _show_wave_complete_message(wave_number: int):
	"""Show wave completion message"""
	var message = Label.new()
	message.text = "Wave " + str(wave_number) + " Complete!"
	message.add_theme_color_override("font_color", Constants.COLOR_ECO_GREEN)
	message.position = Vector2(get_viewport().size.x / 2 - 100, get_viewport().size.y / 2)
	add_child(message)
	
	# Animate message
	var tween = create_tween()
	tween.tween_property(message, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(message, "scale", Vector2.ONE, 0.3)
	tween.tween_delay(2.0)
	tween.parallel().tween_property(message, "modulate:a", 0.0, 0.5)
	tween.tween_callback(message.queue_free)

func show_points_earned(points: int, material_type: String):
	"""Show EcoPuntos earned message"""
	var message = Label.new()
	message.text = "+" + str(points) + " EcoPuntos (" + material_type.capitalize() + ")"
	message.add_theme_color_override("font_color", Constants.COLOR_ECO_BLUE)
	message.position = Vector2(20, get_viewport().size.y - 100)
	add_child(message)
	
	# Animate message
	var tween = create_tween()
	tween.parallel().tween_property(message, "position:y", message.position.y - 50, 2.0)
	tween.parallel().tween_property(message, "modulate:a", 0.0, 2.0)
	tween.tween_callback(message.queue_free)

# 🎮 Public API
func set_total_waves(total: int):
	"""Set total number of waves"""
	total_waves = total
	_update_wave_display()

func show_tower_info(tower_data: Dictionary):
	"""Show tower information panel"""
	# This would show detailed tower stats when tower is selected
	print("🔍 Showing tower info: ", tower_data)

func hide_tower_info():
	"""Hide tower information panel"""
	print("🔍 Hiding tower info")

func update_eco_connection_status(is_connected: bool):
	"""Update EcoPuntos connection status"""
	# Add connection indicator
	var status_color = Constants.COLOR_ECO_GREEN if is_connected else Constants.COLOR_DANGER_RED
	var status_text = "🌐 " + ("Connected" if is_connected else "Offline")
	
	# You could add a connection status label here
	print("🌐 EcoPuntos connection: ", status_text)