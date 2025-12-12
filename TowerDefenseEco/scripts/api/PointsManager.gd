extends Node
class_name PointsManager

# ===================================
# EcoPuntos Tower Defense - Points Manager
# ===================================

signal points_awarded(points: int, material_type: String)
signal points_sync_completed(total_points: Dictionary)
signal points_error(error_message: String)

# 💰 Points tracking
var pending_points: Dictionary = {
	"plastic": 0,
	"glass": 0,
	"paper": 0,
	"metal": 0
}

var offline_points: Dictionary = {
	"plastic": 0,
	"glass": 0,
	"paper": 0,
	"metal": 0
}

# 🔄 Sync state
var is_syncing: bool = false
var last_sync_time: float = 0.0
var auto_sync_interval: float = 60.0  # Auto-sync every minute

func _ready():
	print("💰 PointsManager initialized")

func _process(delta):
	# Auto-sync points periodically
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_sync_time > auto_sync_interval and not is_syncing:
		_auto_sync_points()

func add_points(points: int, material_type: String, base_url: String, token: String, http_request: HTTPRequest) -> bool:
	"""Add points to user's account"""
	if points <= 0:
		print("⚠️ Invalid points amount: ", points)
		return false
	
	if not material_type in ["plastic", "glass", "paper", "metal"]:
		print("⚠️ Invalid material type: ", material_type)
		return false
	
	# Add to pending points
	pending_points[material_type] += points
	
	print("💎 Added ", points, " ", material_type, " points (pending)")
	
	# Try to sync immediately
	sync_points(base_url, token, http_request)
	
	return true

func sync_points(base_url: String, token: String, http_request: HTTPRequest):
	"""Sync pending points with server"""
	if is_syncing:
		print("🔄 Sync already in progress")
		return
	
	if token == "":
		# Store as offline points if not authenticated
		_store_offline_points()
		return
	
	# Check if we have points to sync
	var total_pending = _get_total_pending_points()
	if total_pending == 0:
		print("✅ No points to sync")
		return
	
	is_syncing = true
	
	# Prepare points update data
	var update_data = _prepare_points_update()
	
	# Send to server
	_send_points_update(update_data, base_url, token, http_request)

func _prepare_points_update() -> Dictionary:
	"""Prepare points update for API"""
	var update_data = {}
	
	# Add pending points to update data
	for material_type in pending_points:
		var points = pending_points[material_type]
		if points > 0:
			var field_name = _get_points_field_name(material_type)
			update_data[field_name] = points  # Will be added to existing points on server
	
	return update_data

func _get_points_field_name(material_type: String) -> String:
	"""Get the field name for the material type in the API"""
	match material_type:
		"plastic":
			return "puntos_juego"
		"glass":
			return "puntos_juego_vidrios"
		"paper":
			return "puntos_juego_papel"
		"metal":
			return "puntos_juego_metales"
		_:
			return "puntos_juego"

func _send_points_update(update_data: Dictionary, base_url: String, token: String, http_request: HTTPRequest):
	"""Send points update to server"""
	var headers = PackedStringArray()
	headers.append("Authorization: Bearer " + token)
	headers.append("Content-Type: application/json")
	
	var url = base_url + "usuarios/actualizar-perfil/"
	var json_data = JSON.stringify(update_data)
	
	print("📤 Sending points update: ", update_data)
	http_request.request(url, headers, HTTPClient.METHOD_PUT, json_data)

func handle_points_response(response_code: int, data: Dictionary):
	"""Handle points update response from server"""
	is_syncing = false
	last_sync_time = Time.get_unix_time_from_system()
	
	if response_code == 200:
		_handle_successful_sync(data)
	else:
		_handle_sync_error(response_code, data)

func _handle_successful_sync(data: Dictionary):
	"""Handle successful points sync"""
	print("✅ Points synced successfully")
	
	# Clear pending points that were successfully synced
	var synced_points = pending_points.duplicate()
	
	for material_type in synced_points:
		if synced_points[material_type] > 0:
			points_awarded.emit(synced_points[material_type], material_type)
	
	# Clear pending points
	pending_points = {
		"plastic": 0,
		"glass": 0,
		"paper": 0,
		"metal": 0
	}
	
	# Extract points from response if available
	var total_points = _extract_points_from_response(data)
	points_sync_completed.emit(total_points)

func _handle_sync_error(response_code: int, data: Dictionary):
	"""Handle points sync error"""
	var error_msg = "Failed to sync points (HTTP " + str(response_code) + ")"
	if data.has("detail"):
		error_msg += ": " + str(data["detail"])
	
	print("❌ ", error_msg)
	
	# Store as offline points
	_store_offline_points()
	
	points_error.emit(error_msg)

func _extract_points_from_response(data: Dictionary) -> Dictionary:
	"""Extract points information from API response"""
	var points_data = {}
	
	# Extract points fields from user data
	if data.has("puntos_juego"):
		points_data["plastic"] = data["puntos_juego"]
	if data.has("puntos_juego_vidrios"):
		points_data["glass"] = data["puntos_juego_vidrios"]
	if data.has("puntos_juego_papel"):
		points_data["paper"] = data["puntos_juego_papel"]
	if data.has("puntos_juego_metales"):
		points_data["metal"] = data["puntos_juego_metales"]
	if data.has("puntos"):
		points_data["total"] = data["puntos"]
	
	return points_data

func _store_offline_points():
	"""Store pending points as offline points"""
	for material_type in pending_points:
		offline_points[material_type] += pending_points[material_type]
	
	# Clear pending points
	pending_points = {
		"plastic": 0,
		"glass": 0,
		"paper": 0,
		"metal": 0
	}
	
	print("💾 Points stored offline: ", offline_points)

func _auto_sync_points():
	"""Auto-sync points if we have any pending or offline"""
	var total_pending = _get_total_pending_points()
	var total_offline = _get_total_offline_points()
	
	if total_pending > 0 or total_offline > 0:
		print("🔄 Auto-syncing points...")
		# Note: This would need access to the main API client for the actual sync
		# For now, just log that auto-sync would happen

func _get_total_pending_points() -> int:
	"""Get total pending points across all materials"""
	var total = 0
	for material_type in pending_points:
		total += pending_points[material_type]
	return total

func _get_total_offline_points() -> int:
	"""Get total offline points across all materials"""
	var total = 0
	for material_type in offline_points:
		total += offline_points[material_type]
	return total

func get_pending_points() -> Dictionary:
	"""Get current pending points"""
	return pending_points.duplicate()

func get_offline_points() -> Dictionary:
	"""Get current offline points"""
	return offline_points.duplicate()

func clear_offline_points():
	"""Clear offline points (call after successful sync)"""
	offline_points = {
		"plastic": 0,
		"glass": 0,
		"paper": 0,
		"metal": 0
	}

func merge_offline_points():
	"""Merge offline points into pending points for sync"""
	for material_type in offline_points:
		pending_points[material_type] += offline_points[material_type]
	
	clear_offline_points()
	print("🔄 Merged offline points into pending")

# 📊 Statistics and Info
func get_points_statistics() -> Dictionary:
	"""Get detailed points statistics"""
	return {
		"pending": pending_points.duplicate(),
		"offline": offline_points.duplicate(),
		"total_pending": _get_total_pending_points(),
		"total_offline": _get_total_offline_points(),
		"is_syncing": is_syncing,
		"last_sync_time": last_sync_time
	}

func calculate_material_bonus(material_type: String, base_points: int) -> int:
	"""Calculate bonus points based on material type"""
	var bonus_multiplier = 1.0
	
	# Different materials have different values in recycling
	match material_type:
		"metal":
			bonus_multiplier = 1.5  # Metals are more valuable
		"glass":
			bonus_multiplier = 1.3  # Glass is moderately valuable
		"plastic":
			bonus_multiplier = 1.0  # Base value
		"paper":
			bonus_multiplier = 0.8  # Paper is less valuable but important
	
	return int(base_points * bonus_multiplier)

func validate_points_data(data: Dictionary) -> bool:
	"""Validate points data structure"""
	var required_fields = ["plastic", "glass", "paper", "metal"]
	
	for field in required_fields:
		if not data.has(field):
			return false
		if typeof(data[field]) != TYPE_INT:
			return false
		if data[field] < 0:
			return false
	
	return true
