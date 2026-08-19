extends Node
class_name EnemyManager
# ===================================
# EcoPuntos Tower Defense - Enemy Manager
# ===================================

## 🔔 Signals
signal enemy_defeated(enemy)
signal enemy_reached_end(enemy)
signal all_enemies_defeated()

func _ready():
	print("👾 EnemyManager initialized successfully")