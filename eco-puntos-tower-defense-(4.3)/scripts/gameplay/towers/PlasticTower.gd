extends BaseTower
class_name PlasticTower

# ===================================
# EcoPuntos Tower Defense - Plastic Recycling Tower
# ===================================

func _ready():
	# Set plastic tower specific properties
	tower_type = Constants.TowerType.PLASTIC
	tower_name = "Plastic Recycler"
	build_cost = 60
	damage = 30
	fire_rate = 1.5
	range_radius = 110.0
	projectile_speed = 350.0
	
	# Plastic towers are effective against plastic waste
	target_priority = TargetPriority.WEAKEST  # Focus on finishing off enemies
	
	# Call parent ready
	super._ready()

func _setup_tower_visuals():
	"""Setup plastic tower specific visuals"""
	super._setup_tower_visuals()
	
	# Set plastic tower colors
	if sprite:
		sprite.modulate = Color(1.0, 0.9, 0.2, 1.0)  # Yellow plastic color
	
	if range_indicator:
		range_indicator.modulate = Color(1.0, 0.9, 0.2, 0.3)

func _setup_projectile():
	"""Setup plastic-specific projectile"""
	projectile_scene = preload("res://scenes/gameplay/projectiles/RecycleBullet.tscn")

func _apply_upgrade():
	"""Apply plastic tower specific upgrades"""
	super._apply_upgrade()
	
	# Plastic tower specific improvements
	match level:
		2:
			# Level 2: Faster firing and splash damage
			damage += 10
			projectile_speed += 50
		3:
			# Level 3: Multi-shot capability
			damage += 15
			fire_rate *= 1.3

func _fire_projectile():
	"""Override to add multi-shot at level 3"""
	if level >= 3:
		_fire_multi_shot()
	else:
		super._fire_projectile()

func _fire_multi_shot():
	"""Fire multiple projectiles at level 3"""
	if not projectile_scene or not current_target:
		return
	
	var shot_count = 3
	var spread_angle = PI / 6  # 30 degrees spread
	
	for i in range(shot_count):
		var projectile = projectile_scene.instantiate()
		if not projectile:
			continue
		
		# Add to scene
		get_tree().current_scene.add_child(projectile)
		
		# Calculate spread
		var angle_offset = (i - 1) * spread_angle / 2
		var target_position = current_target.global_position
		var spread_distance = 30.0
		var spread_target = target_position + Vector2(
			cos(current_target.global_position.angle_to_point(global_position) + angle_offset) * spread_distance,
			sin(current_target.global_position.angle_to_point(global_position) + angle_offset) * spread_distance
		)
		
		# Setup projectile with spread
		projectile.global_position = global_position
		projectile.setup_projectile_to_position(spread_target, damage, projectile_speed, self)
	
	# Start fire timer
	fire_timer.start()
	
	# Play effects
	_play_fire_effects()

# 💡 Special Abilities
func get_effectiveness_against(enemy_type: Constants.EnemyType) -> float:
	"""Get damage effectiveness against enemy type"""
	match enemy_type:
		Constants.EnemyType.PLASTIC_WASTE:
			return 1.5  # 150% damage against plastic
		Constants.EnemyType.PAPER_WASTE:
			return 1.1  # 110% damage against paper (recycling synergy)
		_:
			return 1.0  # Normal damage against others

func get_special_description() -> String:
	"""Get description of tower's special abilities"""
	match level:
		1:
			return "Effective against plastic waste. Fast firing rate."
		2:
			return "Increased damage and speed. Small splash effect."
		3:
			return "Multi-shot capability. Triple projectile barrage."
		_:
			return "Plastic recycling tower."