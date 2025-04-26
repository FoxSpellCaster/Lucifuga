extends Control

@onready var title_input = $VBoxContainer/TitleInput
@onready var description_input = $VBoxContainer/DescriptionInput
@onready var steps_input = $VBoxContainer/StepsInput
@onready var steam_id_input = $VBoxContainer/SteamIDInput
@onready var feedback_label = $VBoxContainer/FeedbackLabel

var config = ConfigFile.new()
var api_key = ""

func _ready():
	# Load API key from config.ini
	var err = config.load("res://config.ini")
	if err == OK:
		api_key = config.get_value("server", "api_key", "")
	else:
		feedback_label.text = "Error: Could not load config.ini"
		feedback_label.modulate = Color(1, 0.411765, 0.411765, 1)  # Soft red

func _on_submit_button_pressed():
	# Clear previous feedback
	feedback_label.text = ""
	feedback_label.modulate = Color(1, 0.411765, 0.411765, 1)

	# Validate inputs
	var title = title_input.text.strip_edges()
	var description = description_input.text.strip_edges()
	var steps = steps_input.text.strip_edges()
	var steam_id = steam_id_input.text.strip_edges()

	if title == "":
		feedback_label.text = "Please enter a title."
		return
	if description == "":
		feedback_label.text = "Please enter a description."
		return
	if steps == "":
		feedback_label.text = "Please enter steps to reproduce."
		return

	# Prepare the HTTP request
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_request_completed)

	var url = "http://foxden.servebeer.com:7782/report"
	var headers = ["Content-Type: application/json", "x-api-key: " + api_key]
	var body = JSON.stringify({
		"title": title,
		"description": description,
		"steps": steps,
		"category": "bug",  # Hardcoded to bug since endpoint only accepts this
		"steam_id": steam_id if steam_id != "" else "Anonymous"
	})

	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		feedback_label.text = "Error: Failed to send request to RubberFox."
		http_request.queue_free()

func _on_request_completed(result, response_code, headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	if response_code == 200:
		feedback_label.text = "Bug report successfully sent to RubberFox!"
		feedback_label.modulate = Color(0.545098, 0.913725, 1, 1)  # Cyan glow
		# Clear the form
		title_input.text = ""
		description_input.text = ""
		steps_input.text = ""
		steam_id_input.text = ""
	else:
		var error_message = response if response is String else "Unknown error"
		if response_code == 400 and error_message == "Invalid category. Use /feature-request for features.":
			feedback_label.text = "Feature requests are not supported here. Use /feature-request in Discord!"
		else:
			feedback_label.text = "Error: " + error_message

	# Clean up the HTTPRequest node
	var http_request = get_node_or_null("HTTPRequest")
	if http_request:
		http_request.queue_free()