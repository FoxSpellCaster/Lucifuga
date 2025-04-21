extends Node

# Folders to ignore
var ignore_folders = [".git", ".github", ".godot", "addons"]

# Files to ignore (exact matches)
var ignore_files_exact = [".editorconfig", ".gitattributes", ".gitignore"]

# File patterns to ignore (wildcards)
var ignore_files_patterns = ["*.import", "*.png~", "*.uid", "*.blend1", "*.unwrap_cache", "*.temp", "*.kra~"]

func _ready():
	var output_file = FileAccess.open("user://file_tree.txt", FileAccess.WRITE)
	if output_file:
		print("Generating file tree, ignoring folders: ", ignore_folders)
		print("Ignoring files: ", ignore_files_exact, ", patterns: ", ignore_files_patterns)
		write_file_tree("res://", 0, output_file)
		output_file.close()
		print("File tree saved to user://file_tree.txt")
	else:
		print("Error opening file for writing")

func write_file_tree(path: String, indent_level: int, file: FileAccess):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != "..":
				var full_path = path + ("/" if path != "res://" else "") + file_name
				# Skip ignored folders
				if dir.current_is_dir() and file_name in ignore_folders:
					file_name = dir.get_next()
					continue
				# Skip ignored files (exact matches and patterns)
				if not dir.current_is_dir() and should_ignore_file(file_name):
					file_name = dir.get_next()
					continue
				file.store_line("  ".repeat(indent_level) + file_name)
				if dir.current_is_dir():
					write_file_tree(full_path, indent_level + 1, file)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Error accessing path: ", path)

func should_ignore_file(file_name: String) -> bool:
	# Check exact matches
	if file_name in ignore_files_exact:
		return true
	# Check patterns
	for pattern in ignore_files_patterns:
		if pattern.begins_with("*."):
			var extension = pattern.substr(2)
			if file_name.ends_with(extension) or (extension == "png~" and file_name.ends_with(".png~")):
				return true
	return false
