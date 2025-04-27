extends Control

var api_key = ""

func _ready():
	# Load API key from api_config.tres
	var config = load("res://api_config.tres")
	if config and config is Resource and config.api_key != "":
		api_key = config.api_key
	else:
		print("Error: Could not load API key from api_config.tres")
		return

	# Ensure Steam is initialized
	if not Steam.steamInit():
		print("Error: Failed to initialize Steam")
		return

	# Get Steam persona name and ID
	var persona_name = Steam.getPersonaName()
	var steam_id = str(Steam.getSteamID())

	# Log the spawn to Discord
	log_spawn(persona_name, steam_id)

func log_spawn(persona_name: String, steam_id: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_log_spawn_completed)

	var url = "http://foxden.servebeer.com:7782/log-spawn"
	var headers = ["Content-Type: application/json", "x-api-key: " + api_key]
	var body = JSON.stringify({
		"persona_name": persona_name,
		"steam_id": steam_id
	})

	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("Error: Failed to send spawn log to RubberFox")
		http_request.queue_free()

func _on_log_spawn_completed(result, response_code, headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	if response_code == 200:
		print("Spawn logged to RubberFox successfully")
	else:
		var error_message = response if response is String else "Unknown error"
		print("Error logging spawn: " + error_message)

	# Clean up the HTTPRequest node
	var http_request = get_node_or_null("HTTPRequest")
	if http_request:
		http_request.queue_free()
