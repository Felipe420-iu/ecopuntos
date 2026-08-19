extends Node
class_name AuthManager

# ===================================
# EcoPuntos Tower Defense - Authentication Manager
# ===================================

signal authentication_successful(token: String, user_data: Dictionary)
signal authentication_failed(error_message: String)

# 🔐 Login state
var current_request_type: RequestType = RequestType.NONE
var login_credentials: Dictionary = {}

enum RequestType {
	NONE,
	LOGIN,
	REFRESH,
	VERIFY
}

func _ready():
	print("🔐 AuthManager initialized")

func login(username: String, password: String, base_url: String, http_request: HTTPRequest):
	"""Attempt to login with username and password"""
	if current_request_type != RequestType.NONE:
		print("⚠️ Authentication request already in progress")
		return
	
	# Store credentials for potential retry
	login_credentials = {
		"username": username,
		"password": password
	}
	
	# Prepare request
	current_request_type = RequestType.LOGIN
	
	var headers = PackedStringArray()
	headers.append("Content-Type: application/json")
	
	var login_data = {
		"username": username,
		"password": password
	}
	
	var url = base_url + "auth/login/"
	var json_data = JSON.stringify(login_data)
	
	print("🔑 Attempting login for user: ", username)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)

func handle_auth_response(response_code: int, data: Dictionary):
	"""Handle authentication response from API"""
	match current_request_type:
		RequestType.LOGIN:
			_handle_login_response(response_code, data)
		RequestType.REFRESH:
			_handle_refresh_response(response_code, data)
		RequestType.VERIFY:
			_handle_verify_response(response_code, data)
	
	current_request_type = RequestType.NONE

func _handle_login_response(response_code: int, data: Dictionary):
	"""Handle login response"""
	if response_code == 200:
		if data.has("access") and data.has("refresh"):
			var token = data["access"]
			var refresh_token = data["refresh"]
			
			# Get user data (if included in response)
			var user_data = data.get("user", {})
			
			print("✅ Login successful")
			authentication_successful.emit(token, user_data)
		else:
			print("❌ Login failed: Invalid response format")
			authentication_failed.emit("Invalid response format")
	else:
		var error_msg = data.get("detail", "Login failed")
		if data.has("non_field_errors"):
			error_msg = data["non_field_errors"][0] if data["non_field_errors"].size() > 0 else error_msg
		
		print("❌ Login failed: ", error_msg)
		authentication_failed.emit(error_msg)

func _handle_refresh_response(response_code: int, data: Dictionary):
	"""Handle token refresh response"""
	if response_code == 200 and data.has("access"):
		var new_token = data["access"]
		print("🔄 Token refreshed successfully")
		authentication_successful.emit(new_token, {})
	else:
		print("❌ Token refresh failed")
		authentication_failed.emit("Token refresh failed")

func _handle_verify_response(response_code: int, data: Dictionary):
	"""Handle token verification response"""
	if response_code == 200:
		print("✅ Token verified successfully")
	else:
		print("❌ Token verification failed")
		authentication_failed.emit("Token expired")

func refresh_token(refresh_token: String, base_url: String, http_request: HTTPRequest):
	"""Refresh access token using refresh token"""
	current_request_type = RequestType.REFRESH
	
	var headers = PackedStringArray()
	headers.append("Content-Type: application/json")
	
	var refresh_data = {
		"refresh": refresh_token
	}
	
	var url = base_url + "auth/refresh/"
	var json_data = JSON.stringify(refresh_data)
	
	print("🔄 Refreshing access token")
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)

func verify_token(token: String, base_url: String, http_request: HTTPRequest):
	"""Verify if token is still valid"""
	current_request_type = RequestType.VERIFY
	
	var headers = PackedStringArray()
	headers.append("Content-Type: application/json")
	
	var verify_data = {
		"token": token
	}
	
	var url = base_url + "auth/verify/"
	var json_data = JSON.stringify(verify_data)
	
	print("🔍 Verifying token")
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)

func get_current_request_type() -> RequestType:
	"""Get current authentication request type"""
	return current_request_type

func clear_credentials():
	"""Clear stored login credentials"""
	login_credentials.clear()

func has_stored_credentials() -> bool:
	"""Check if we have stored credentials"""
	return login_credentials.has("username") and login_credentials.has("password")

func retry_login(base_url: String, http_request: HTTPRequest):
	"""Retry login with stored credentials"""
	if not has_stored_credentials():
		authentication_failed.emit("No stored credentials for retry")
		return
	
	var username = login_credentials["username"]
	var password = login_credentials["password"]
	login(username, password, base_url, http_request)
