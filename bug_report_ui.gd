extends Control

var server_url: String = ""
var api_key: String = ""

func _ready():
	# Ensure the development setting exists
	if not ProjectSettings.has_setting("lucifuga/is_development"):
		ProjectSettings.set_setting("lucifuga/is_development", true)
		ProjectSettings.save()

	# Load config only in editor or development mode
	if OS.has_feature("editor") or ProjectSettings.get_setting("lucifuga/is_development", false):
		if not FileAccess.file_exists("res://config.ini"):
			print("Config file not found at res://config.ini")
			$MainContainer/StatusLabel.text = "Configuration file missing"
			$MainContainer/SubmitButton.disabled = true
			return

		# Read and parse the config file manually
		var file = FileAccess.open("res://config.ini", FileAccess.READ)
		if file:
			print("Config file contents:")
			var content = file.get_as_text()
			print(content)
			file.close()

			# Parse the INI content
			var current_section = ""
			for line in content.split("\n"):
				line = line.strip_edges()  # Remove leading/trailing whitespace
				if line.is_empty() or line.begins_with(";"):  # Skip empty lines or comments
					continue
				if line.begins_with("[") and line.ends_with("]"):
					current_section = line.substr(1, line.length() - 2)
					continue
				if current_section == "discord" and "=" in line:
					var parts = line.split("=", false, 1)
					if parts.size() == 2:
						var key = parts[0].strip_edges()
						var value = parts[1].strip_edges()
						if key == "server_url":
							server_url = value
						elif key == "api_key":
							api_key = value

			if server_url.is_empty() or api_key.is_empty():
				print("Failed to parse config: server_url or api_key missing")
				$MainContainer/StatusLabel.text = "Configuration parsing error"
				$MainContainer/SubmitButton.disabled = true
				return
			else:
				print("Config parsed manually: Server URL = ", server_url)
		else:
			print("Failed to open config file: ", FileAccess.get_open_error())
			$MainContainer/StatusLabel.text = "Configuration error"
			$MainContainer/SubmitButton.disabled = true
			return
	else:
		$MainContainer/StatusLabel.text = "Bug reporting disabled. Use /report in Discord!"
		$MainContainer/SubmitButton.disabled = true
		return

	# Populate category dropdown
	$MainContainer/CategoryOption.add_item("Bug", 0)
	$MainContainer/CategoryOption.add_item("Feedback", 1)
	$MainContainer/CategoryOption.add_item("Feature", 2)

	# Connect signals
	$MainContainer/SubmitButton.pressed.connect(_on_submit_button_pressed)
	$HTTPRequest.request_completed.connect(_on_request_completed)

func _on_submit_button_pressed():
	var title = $MainContainer/TitleEdit.text
	var description = $MainContainer/DescriptionEdit.text
	var steps = $MainContainer/StepsEdit.text
	var category = ["bug", "feedback", "feature"][$MainContainer/CategoryOption.selected]
	var steam_id = Steam.getSteamID()

	if title.is_empty() or description.is_empty() or steps.is_empty():
		$MainContainer/StatusLabel.text = "Please fill all fields"
		$MainContainer/StatusLabel.modulate = Color(1, 0, 0)  # Red for error
		return

	submit_bug_report(title, description, steps, category, str(steam_id))

func submit_bug_report(title: String, description: String, steps: String, category: String, steam_id: String):
	if server_url.is_empty() or api_key.is_empty():
		$MainContainer/StatusLabel.text = "Error: Server not configured"
		$MainContainer/StatusLabel.modulate = Color(1, 0, 0)
		return

	var headers = [
		"Content-Type: application/json",
		"X-API-Key: %s" % api_key
	]
	var body = {
		"title": title,
		"description": description,
		"steps": steps,
		"category": category,
		"steam_id": steam_id if steam_id else "Anonymous"
	}

	$HTTPRequest.request(server_url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	$MainContainer/StatusLabel.text = "Submitting report..."
	$MainContainer/StatusLabel.modulate = Color(1, 1, 1)  # White while submitting

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		$MainContainer/StatusLabel.tex
