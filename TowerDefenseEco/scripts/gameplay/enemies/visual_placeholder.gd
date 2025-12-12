@tool
extends Node2D

@export var color: Color = Color(0.8, 0.8, 0.9, 1.0)
@export var radius: float = 18.0

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)
