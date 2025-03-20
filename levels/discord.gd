extends Node

# Replace this with your Discord webhook URL
const WEBHOOK_URL = ""

# Reference to the HTTPRequest node (assign this in the editor or via code)
@onready var http_request = $HTTPRequest

func _ready():
	# Connect the request_completed signal to handle the response
	http_request.request_completed.connect(_on_request_completed)
	
	# Example: Send a message when the scene loads
	send_discord_message("Hello from Godot 4.4!")

func send_discord_message(message: String):
	# Prepare the JSON payload for Discord
	var payload = {
		"content": message,
		"username": "Godot Bot",  # Optional: Customize the bot's name
		"avatar_url": "https://godotengine.org/assets/logo.png"  # Optional: Customize the avatar
	}
	
	# Convert the payload to a JSON string
	var json_payload = JSON.stringify(payload)
	
	# Set up headers for the HTTP request
	var headers = ["Content-Type: application/json"]
	
	# Send the POST request to the Discord webhook
	var error = http_request.request(WEBHOOK_URL, headers, HTTPClient.METHOD_POST, json_payload)
	
	if error != OK:
		print("Error sending request: ", error)

# Handle the response from the Discord server
func _on_request_completed(result, response_code, headers, body):
	if response_code == 204:  # Discord returns 204 No Content on success
		print("Message sent to Discord successfully!")
	else:
		print("Failed to send message. Response code: ", response_code)
		print("Response body: ", body.get_string_from_utf8())
