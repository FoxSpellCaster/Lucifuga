extends Node

func get_webhook_url() -> String:
	var file = FileAccess.open("res://configs/webhook_config.json", FileAccess.READ)
	if file == null:
		print("Error: Could not open webhook_config.json!")
		return ""
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		print("Error parsing JSON: %s" % json.get_error_message())
		return ""
	var data = json.data
	if data.has("webhook_url"):
		return data.webhook_url
	print("Error: webhook_url not found in JSON!")
	return ""

func send_webhook(message: String) -> void:
	var url = get_webhook_url()
	if url == "":
		print("Error: Cannot send webhook, URL is empty!")
		return
	var http = HTTPRequest.new()
	add_child(http)
	http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify({"content": message}))
