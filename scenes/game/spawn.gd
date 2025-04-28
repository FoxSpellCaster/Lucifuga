extends Node

@onready var http_request = $HTTPRequest  # Add an HTTPRequest node to your scene

func _ready():
	http_request.request_completed.connect(_on_request_completed)
	# Example: Call this function when a player spawns
	log_spawn("PlayerName", "76561197993670373")

func log_spawn(persona_name: String, steam_id: String):
	var url = "http://your-server-address:7782/log-spawn"
	var headers = ["Content-Type: application/json", "x-api-key: " + "38668777-e815-4a2f-8010-a221cc1f7c05"]
	var body = {
		"persona_name": persona_name,
		"steam_id": steam_id
	}
	var json = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json)

func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("HTTP request failed: ", result)
		return
	
	if response_code != 200:
		print("HTTP response code: ", response_code)
		return
	
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		print("JSON parse error: ", json.get_error_message())
		return
	
	var response = json.data
	if response.status == "success":
		print("Spawn logged successfully: ", response.message)
	else:
		print("Spawn log failed: ", response.message)
