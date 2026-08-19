extends Node
class_name TowerManager
# ===================================
# EcoPuntos Tower Defense - Tower Manager
# ===================================

## 🔔 Signals
signal tower_built(tower, position)
signal tower_sold(tower, refund_amount)
signal tower_upgraded(tower, new_level)

func _ready():
	print("🏗️ TowerManager initialized successfully")