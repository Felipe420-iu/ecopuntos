extends Control
# ===================================
# EcoPuntos Tower Defense - Damage Number Effect
# ===================================

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	print("💥 DamageNumber effect initialized")

func show_damage(damage_amount: int, position: Vector2):
	"""Display damage number with animation"""
	if label:
		label.text = "-" + str(damage_amount)
	
	# Set position
	global_position = position
	
	# Simple animation (move up and fade out)
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move up
	tween.tween_property(self, "position", position + Vector2(0, -50), 1.0)
	
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	
	# Remove after animation
	tween.tween_callback(queue_free).set_delay(1.0)