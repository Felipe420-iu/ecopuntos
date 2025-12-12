extends Node
class_name GameManager

# ===================================
# EcoPuntos Tower Defense - Game Manager BÁSICO
# ===================================

@warning_ignore("unused_signal")
signal game_started
signal money_changed(new_amount: int)
signal lives_changed(new_amount: int)

var money: int = 150
var lives: int = 20
var score: int = 0

func _ready():
	print("🎮 GameManager initialized!")
	print("💰 Starting money: ", money)
	print("❤️ Starting lives: ", lives)
	
	# Test básico
	add_money(50)
	lose_life(1)

func add_money(amount: int):
	money += amount
	money_changed.emit(money)
	print("💰 Money: ", money)

func lose_life(amount: int = 1):
	lives -= amount
	lives_changed.emit(lives)
	print("❤️ Lives: ", lives)
	
	if lives <= 0:
		print("💀 GAME OVER!")
