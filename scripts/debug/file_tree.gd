extends Node

# Configuration for ignored folders and files
const IGNORE_FOLDERS := [".git", ".github", ".godot", "addons"]
const IGNORE_FILES_EXACT := [".editorconfig", ".gitattributes", ".gitignore"]
const IGNORE_FILES_PATTERNS := ["*.import", "*.png~", "*.uid", "*.blend1", "*.unwrap_cache", "*.temp", "*.kra~"]

func _ready() -> void:
	var output_file := FileAccess.open("user://file_tree.txt", FileAccess.WRITE)
	if output_file:
		print("Generating file tree, ignoring folders: %s" % [IGNORE_FOLDERS])
		print("Ignoring files: %s, patterns: %s" % [IGNORE_FILES_EXACT, IGNORE_FILES_PATTERNS])
		_generate_file_tree("res://", 0, output_file)
		output_file.close()
		print("File tree saved to user://file_tree.txt")
	else:
		printerr("Failed to open file for writing")

func _generate_file_tree(path: String, indent_level: int, file: FileAccess) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		printerr("Failed to access path: %s" % path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name:
		if file_name in [".", ".."]:
			file_name = dir.get_next()
			continue

		var full_path := path + ("/" if path != "res://" else "") + file_name
		if dir.current_is_dir():
			if file_name not in IGNORE_FOLDERS:
				file.store_line("  ".repeat(indent_level) + file_name)
				_generate_file_tree(full_path, indent_level + 1, file)
		elif not _should_ignore_file(file_name):
			file.store_line("  ".repeat(indent_level) + file_name)

		file_name = dir.get_next()
	dir.list_dir_end()

func _should_ignore_file(file_name: String) -> bool:
	if file_name in IGNORE_FILES_EXACT:
		return true

	for pattern in IGNORE_FILES_PATTERNS:
		var extension: String
		if pattern.begins_with("*."):
			extension = pattern.substr(2)
		else:
			extension = pattern
		if file_name.ends_with(extension):
			return true
	return false
