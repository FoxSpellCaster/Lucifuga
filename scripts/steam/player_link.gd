extends Node

# Steam ID and linking state
var steam_id: int = 0
var link_code: String = ""
var is_linked: bool = false

# File to store linking status locally
const LINK_FILE_PATH: String = "user://discord_link.dat"

# HTTP request node to communicate with the server
var http_request: HTTPRequest = null

# Reference to the Code label
@onready var code_label: Label = $Code

# Flag to track if a request is in progress
var is_requesting: bool = false

# Polling settings
const POLLING_INTERVAL: float = 15.0  # Increased from 5 to 15 seconds
const MAX_POLLING_ATTEMPTS: int = 20  # Stop after ~5 minutes (20 * 15s)
var polling_attempts: int = 0

func _ready() -> void:
	# Initialize GodotSteam
	if not Steam.steamInit():
		print("Failed to initialize Steam")
		return

	# Get the player's Steam ID
	steam_id = Steam.getSteamID()
	if steam_id == 0:
		print("Failed to retrieve Steam ID")
		return

	# Check if the player is already linked
	load_link_status()

	if not is_linked:
		# Hide the label initially
		code_label.visible = false

		# Generate a unique code for linking
		generate_link_code()

		# Update the Code label with the generated code
		code_label.text = "Link Code: " + link_code
		code_label.visible = true

		# Register the code with the server
		http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.request_completed.connect(_on_http_request_completed)

		var url: String = "http://foxden.servebeer.com:7782/register-link"
		var headers: PackedStringArray = ["Content-Type: application/json"]
		var body: String = JSON.stringify({ "steam_id": str(steam_id), "code": link_code })
		is_requesting = true
		var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
		if error != OK:
			print("Failed to send register-link request: ", error)
			is_requesting = false
			return

		# Wait for the server to commit the database transaction
		await get_tree().create_timer(1.0).timeout

		# Start polling the server to check if the link is complete
		polling_attempts = 0
		poll_link_status()
	else:
		# If already linked, ensure the label is hidden
		code_label.visible = false

func generate_link_code() -> void:
	# Generate a simple 6-character alphanumeric code
	var chars: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	link_code = ""
	for i in range(6):
		link_code += chars[randi() % chars.length()]
	print("Generated link code: ", link_code)

func save_link_status() -> void:
	var file: FileAccess = FileAccess.open(LINK_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_line(str(is_linked))
		file.close()

func load_link_status() -> void:
	if FileAccess.file_exists(LINK_FILE_PATH):
		var file: FileAccess = FileAccess.open(LINK_FILE_PATH, FileAccess.READ)
		if file:
			is_linked = file.get_line().to_lower() == "true"
			file.close()

func poll_link_status() -> void:
	while not is_linked and polling_attempts < MAX_POLLING_ATTEMPTS:
		# Wait if a request is already in progress
		if is_requesting:
			await get_tree().create_timer(0.1).timeout
			continue

		# Send a request to the server to check if the link is complete
		var url: String = "http://foxden.servebeer.com:7782/check-link?steam_id=" + str(steam_id) + "&code=" + link_code
		is_requesting = true
		var error = http_request.request(url)
		if error != OK:
			print("Failed to send check-link request: ", error)
			is_requesting = false

		polling_attempts += 1
		if polling_attempts >= MAX_POLLING_ATTEMPTS:
			print("Max polling attempts reached. Stopping link status checks.")
			break

		# Wait before the next poll
		await get_tree().create_timer(POLLING_INTERVAL).timeout

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	is_requesting = false
	print("HTTP request completed with result: ", result, " and response code: ", response_code)
	print("Raw response body: ", body.get_string_from_utf8())
	
	if response_code == 200:
		var json: JSON = JSON.new()
		var error: int = json.parse(body.get_string_from_utf8())
		if error != OK:
			print("Failed to parse JSON response: ", json.get_error_message())
			return
		
		var data: Dictionary = json.data
		print("Parsed response data: ", data)
		
		if data.get("linked", false):
			is_linked = true
			save_link_status()
			# Hide the label after a successful link
			code_label.visible = false
			print("Discord ID linked successfully!")
		elif data.get("success", false):
			print("Link code registered with the server")
		else:
			print("Link status check failed: ", data.get("error", "Unknown error"))
	else:
		print("HTTP request failed with response code: ", response_code)
