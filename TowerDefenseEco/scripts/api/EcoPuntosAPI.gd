extends Node
class_name EcoPuntosAPI

# ===================================
# EcoPuntos Tower Defense - API Client
# ===================================

signal authentication_changed(is_authenticated: bool)
signal points_updated(points_data: Dictionary)
signal api_error(error_message: String)
signal connection_status_changed(is_connected: bool)

# 🌐 API Configuration
var base_url: String = Constants.API_BASE_URL
var jwt_token: String = ""
var refresh_token: String = ""
var user_data: Dictionary = {}

# 🔗 HTTP Components
var http_request: HTTPRequest
var auth_manager: AuthManager
var points_manager: PointsManager

# 📡 Connection State
var is_connected: bool = false
var last_connection_check: float = 0.0
var connection_check_interval: float = 30.0  # Check every 30 seconds

# 💾 Local Cache
var cached_user_data: Dictionary = {}
var cache_file_path: String = "user://ecopuntos_cache.dat"

func _ready():
	# Setup HTTP request
	_setup_http_request()
	
	# Setup managers
	_setup_managers()
	
	# Load cached data
	_load_cached_data()
	
	# Try auto-authentication if we have cached credentials
	_try_auto_authentication()
	
	print("🌐 EcoPuntos API Client initialized")

func _setup_http_request():
	"""Setup HTTP request node"""
	http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Configure timeouts
	http_request.timeout = 10.0
	
	# Connect signals
	http_request.request_completed.connect(_on_http_request_completed)

func _setup_managers():
	"""Setup sub-managers"""
	auth_manager = AuthManager.new()
	auth_manager.name = "AuthManager"
	add_child(auth_manager)
	
	points_manager = PointsManager.new()
	points_manager.name = "PointsManager"
	add_child(points_manager)
	
	# Connect manager signals
	auth_manager.authentication_successful.connect(_on_authentication_successful)
	auth_manager.authentication_failed.connect(_on_authentication_failed)
	points_manager.points_awarded.connect(_on_points_awarded)

func _process(delta):
	# Periodic connection check
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_connection_check > connection_check_interval:
		_check_connection_status()
		last_connection_check = current_time

# 🔐 Authentication Methods
func login(username: String, password: String):
	"""Login with username and password"""
	if auth_manager:
		auth_manager.login(username, password, base_url, http_request)

func logout():
	"""Logout current user"""
	jwt_token = ""
	refresh_token = ""
	user_data.clear()
	_clear_cached_data()
	authentication_changed.emit(false)
	print("👤 User logged out")

func is_authenticated() -> bool:
	"""Check if user is authenticated"""
	return jwt_token != "" and not _is_token_expired()

func _is_token_expired() -> bool:
	"""Check if JWT token is expired"""
	if jwt_token == "":
		return true
	
	# TODO: Implement proper JWT token validation
	# For now, assume token expires after 24 hours
	return false

func _try_auto_authentication():
	"""Try to authenticate with cached credentials"""
	if cached_user_data.has("jwt_token") and cached_user_data["jwt_token"] != "":
		jwt_token = cached_user_data["jwt_token"]
		if cached_user_data.has("user_data"):
			user_data = cached_user_data["user_data"]
		
		# Validate token with server
		_validate_token()

func _validate_token():
	"""Validate current token with server"""
	var headers = _get_auth_headers()
	var url = base_url + "auth/verify/"
	
	http_request.request(url, headers, HTTPClient.METHOD_POST)

# 💰 Points Management
func add_game_points(points: int, material_type: String = "plastic"):
	"""Add points from game to user's EcoPuntos account"""
	if not is_authenticated():
		print("⚠️ Cannot add points: Not authenticated")
		return false
	
	if points_manager:
		return points_manager.add_points(points, material_type, base_url, jwt_token, http_request)
	
	return false

func get_user_points() -> Dictionary:
	"""Get current user points"""
	if not is_authenticated():
		return {}
	
	var headers = _get_auth_headers()
	var url = base_url + "usuarios/perfil/"
	
	http_request.request(url, headers, HTTPClient.METHOD_GET)
	
	return user_data.get("points", {})

func sync_points():
	"""Sync points with server"""
	if not is_authenticated():
		return
	
	get_user_points()

# 📊 User Data
func get_user_profile() -> Dictionary:
	"""Get complete user profile"""
	return user_data.duplicate()

func update_user_profile(profile_data: Dictionary):
	"""Update user profile on server"""
	if not is_authenticated():
		print("⚠️ Cannot update profile: Not authenticated")
		return
	
	var headers = _get_auth_headers()
	headers.append("Content-Type: application/json")
	
	var url = base_url + "usuarios/actualizar-perfil/"
	var json_data = JSON.stringify(profile_data)
	
	http_request.request(url, headers, HTTPClient.METHOD_PUT, json_data)

# 🏆 Game Integration
func submit_game_results(game_data: Dictionary):
	"""Submit game completion results to server"""
	if not is_authenticated():
		print("⚠️ Cannot submit results: Not authenticated")
		return false
	
	# Prepare game results data
	var results = {
		"game_type": "tower_defense",
		"level": game_data.get("level", 1),
		"score": game_data.get("score", 0),
		"enemies_defeated": game_data.get("enemies_defeated", 0),
		"towers_built": game_data.get("towers_built", 0),
		"time_played": game_data.get("time_played", 0),
		"materials_recycled": game_data.get("materials_recycled", {}),
		"eco_points_earned": game_data.get("eco_points_earned", 0)
	}
	
	# Add points for each material type
	var materials = results.get("materials_recycled", {})
	for material_type in materials:
		var points = materials[material_type]
		if points > 0:
			add_game_points(points, material_type)
	
	print("🏆 Game results submitted: ", results)
	return true

# 🌐 Network Utilities
func _get_auth_headers() -> PackedStringArray:
	"""Get headers with authentication"""
	var headers = PackedStringArray()
	if jwt_token != "":
		headers.append("Authorization: Bearer " + jwt_token)
	return headers

func _check_connection_status():
	"""Check if API is reachable"""
	var headers = PackedStringArray()
	var url = base_url + "auth/verify/"
	
	# Make a simple request to check connectivity
	http_request.request(url, headers, HTTPClient.METHOD_GET)

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	"""Handle HTTP request completion"""
	var response_text = body.get_string_from_utf8()
	
	print("🌐 API Response: ", response_code, " - ", response_text)
	
	# Update connection status
	var was_connected = is_connected
	is_connected = response_code >= 200 and response_code < 300
	
	if was_connected != is_connected:
		connection_status_changed.emit(is_connected)
	
	# Parse response
	if response_text != "":
		var json = JSON.new()
		var parse_result = json.parse(response_text)
		
		if parse_result == OK:
			var data = json.data
			_handle_api_response(response_code, data)
		else:
			print("⚠️ Failed to parse JSON response")
			api_error.emit("Invalid response format")

func _handle_api_response(status_code: int, data: Dictionary):
	"""Handle parsed API response"""
	match status_code:
		200:
			_handle_success_response(data)
		401:
			_handle_authentication_error(data)
		400, 422:
			_handle_validation_error(data)
		500, 502, 503:
			_handle_server_error(data)
		_:
			_handle_unknown_error(status_code, data)

func _handle_success_response(data: Dictionary):
	"""Handle successful API response"""
	# Update user data if profile information is returned
	if data.has("id") and data.has("username"):
		user_data = data
		_cache_user_data()
		points_updated.emit(user_data.get("points", {}))

func _handle_authentication_error(data: Dictionary):
	"""Handle authentication errors"""
	print("🚫 Authentication error: ", data.get("detail", "Unknown error"))
	jwt_token = ""
	refresh_token = ""
	_clear_cached_data()
	authentication_changed.emit(false)
	api_error.emit("Authentication failed: " + data.get("detail", "Unknown error"))

func _handle_validation_error(data: Dictionary):
	"""Handle validation errors"""
	var error_msg = data.get("detail", "Validation error")
	print("⚠️ Validation error: ", error_msg)
	api_error.emit("Validation error: " + error_msg)

func _handle_server_error(data: Dictionary):
	"""Handle server errors"""
	var error_msg = data.get("detail", "Server error")
	print("🔥 Server error: ", error_msg)
	api_error.emit("Server error: " + error_msg)

func _handle_unknown_error(status_code: int, data: Dictionary):
	"""Handle unknown errors"""
	var error_msg = "Unknown error (status " + str(status_code) + ")"
	print("❓ Unknown error: ", error_msg)
	api_error.emit(error_msg)

# 💾 Cache Management
func _cache_user_data():
	"""Save user data to local cache"""
	var cache_data = {
		"jwt_token": jwt_token,
		"refresh_token": refresh_token,
		"user_data": user_data,
			"cached_at": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(cache_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(cache_data))
		file.close()
		print("💾 User data cached")

func _load_cached_data():
	"""Load user data from local cache"""
	var file = FileAccess.open(cache_file_path, FileAccess.READ)
	if not file:
		return
	
	var cache_content = file.get_as_text()
	file.close()
	
	if cache_content == "":
		return
	
	var json = JSON.new()
	var parse_result = json.parse(cache_content)
	
	if parse_result == OK:
		cached_user_data = json.data
		print("📁 Cached user data loaded")

func _clear_cached_data():
	"""Clear local cache"""
	if FileAccess.file_exists(cache_file_path):
		DirAccess.remove_absolute(cache_file_path)
	cached_user_data.clear()
	print("🗑️ Cache cleared")

# 📡 Signal Handlers
func _on_authentication_successful(token: String, user_info: Dictionary):
	"""Handle successful authentication"""
	jwt_token = token
	user_data = user_info
	_cache_user_data()
	authentication_changed.emit(true)
	print("✅ Authentication successful for user: ", user_data.get("username", "Unknown"))

func _on_authentication_failed(error: String):
	"""Handle authentication failure"""
	print("❌ Authentication failed: ", error)
	api_error.emit("Login failed: " + error)

func _on_points_awarded(points: int, material_type: String):
	"""Handle points being awarded"""
	print("💰 Points awarded: ", points, " (", material_type, ")")
	
	# Update local user data
	if not user_data.has("points"):
		user_data["points"] = {}
	
	var points_key = "puntos_juego_" + material_type + "s" if material_type != "plastic" else "puntos_juego"
	user_data["points"][points_key] = user_data["points"].get(points_key, 0) + points
	
	points_updated.emit(user_data.get("points", {}))

# 🎮 Public API for Game
func get_connection_status() -> bool:
	"""Get current connection status"""
	return is_connected

func get_last_error() -> String:
	"""Get last API error message"""
	# This would be stored from the last error signal
	return ""

func force_sync():
	"""Force synchronization with server"""
	if is_authenticated():
		sync_points()
		get_user_profile()

# 🛠️ Development/Debug Methods
func set_api_base_url(url: String):
	"""Set API base URL for testing"""
	base_url = url
	print("🔧 API URL set to: ", base_url)
