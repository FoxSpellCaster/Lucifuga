extends Node


@export var player: VoiceAudioStreamPlayer
@export var head_animation_player: AnimationPlayer
@export var text_edit: TextEdit
@export var text_label: Label

@export var pitch_value_label: Label
@export var pitch_slider: Slider

@export var random_pitch_value_label: Label
@export var random_pitch_slider: Slider

@export var random_volume_offset_value_label: Label
@export var random_volume_offset_slider: Slider

@export var volume_value_label: Label
@export var volume_slider: Slider

@export var word_pause_value_label: Label
@export var word_pause_slider: Slider

@export var punctuation_pause_value_label: Label
@export var punctuation_pause_slider: Slider

@export var question_pitch_scale_value_label: Label
@export var question_pitch_scale_slider: Slider

@export var syllable_size_value_label: Label
@export var syllable_size_slider: Slider

@export var file_option_button: OptionButton

@export var generator_type_button: OptionButton

@export var generator_frequence_value_label: Label
@export var generator_frequence_slider: Slider

@export var generator_frequence2_value_label: Label
@export var generator_frequence2_slider: Slider

@export var generator_length_value_label: Label
@export var generator_length_slider: Slider

@export var generator_amplitude_value_label: Label
@export var generator_amplitude_slider: Slider

@export var generator_noise_value_label: Label
@export var generator_noise_slider: Slider

@export var generator_smooth_iter_value_label: Label
@export var generator_smooth_iter_slider: Slider

@export var sound_source_tab_container: TabContainer

@export var alphabet_pitch_option_button: OptionButton

@export var word_cutting_value_label: Label
@export var word_cutting_slider: Slider

@export var preset_option_button: OptionButton


enum Presets {
	FILE_SIMPLE_SOUND_V,
	FILE_SIMPLE_SOUND_V2,
	SINE_GENERATOR,
	PULSE_GENERATOR,
	ANIMAL_ALPHABET,
	GIRL_ALPHABET,
}


func _ready() -> void:
	player.connect("saying_characters", func(pos: int) -> void: text_label.visible_characters = pos)
	player.connect("saying_characters", func(pos: int) -> void: head_animation_player.play("saying"))
	
	for sub_path: String in ["", "alphabet/high/", "alphabet/med/", "alphabet/low/", "alphabet/lowest/"]:
		var dir := DirAccess.open("res://addons/godot-voice-generator/sound/" + sub_path)
		if dir:
			dir.include_hidden = true
			dir.include_navigational = true
			dir.list_dir_begin()
			var file_name := dir.get_next()
			while file_name != "":
				if not dir.current_is_dir() and file_name.ends_with(".import"):
					var imported_file_name := file_name.replace(".import", "")
					if imported_file_name.ends_with("mp3") or imported_file_name.ends_with("ogg") or imported_file_name.ends_with("wav"):
						file_option_button.add_item(sub_path + imported_file_name)
				file_name = dir.get_next()
		else:
			push_error("An error occurred when trying to access the path.")
	
	for i: String in VoiceAudioStreamPlayer.GENERATOR_TYPE.keys():
		generator_type_button.add_item(i)
	
	for t: String in ["high", "med", "low", "lowest"]:
		alphabet_pitch_option_button.add_item(t)
	update_alphabet_mapping()
	
	preset_option_button.add_item("Not selected", 696969)
	for i: int in Presets.keys().size():
		preset_option_button.add_item(Presets.keys()[i], i)
	
	refresh_ui()


func refresh_ui() -> void:
	_on_pitch_value_changed(player.main_pitch_scale)
	_on_random_pitch_value_changed(player.random_pitch)
	_on_random_volume_offset_value_changed(player.random_volume_offset_db)
	_on_word_pause_value_changed(player.word_pause)
	_on_punctuation_pause_value_changed(player.punctuation_pause)
	_on_question_pitch_scale_value_changed(player.question_pitch_scale)
	_on_syllable_size_value_changed(player.syllable_size)
	_on_volume_value_changed(player.volume_db)
	_on_word_cutting_value_changed(player.word_cutting_percentage)
	
	_on_generator_frequence_value_changed(player.generator_frequence_hz)
	_on_generator_frequence2_value_changed(player.generator_frequence2_hz)
	_on_generator_length_value_changed(player.generator_length)
	_on_generator_amplitude_value_changed(player.generator_amplitude)
	_on_generator_noise_value_changed(player.generator_noise)
	_on_generator_smooth_value_changed(player.generator_smooth_wave)
	
	var sub_stream := player.get_sub_stream() as AudioStream
	var sound_file_name := sub_stream.resource_path.split("/").slice(-1)[0]
	for i: int in file_option_button.item_count:
		if file_option_button.get_item_text(i) == sound_file_name:
			_on_sound_option_button_item_selected(i)
	
	generator_type_button.selected = player.generator_type
	
	sound_source_tab_container.current_tab = player.source_type


func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	text_label.text = text_edit.text
	player.say(text_edit.text)


func _on_pitch_value_changed(value: float) -> void:
	pitch_value_label.text = "%10.2f" % value
	pitch_slider.value = value
	player.main_pitch_scale = value


func _on_random_pitch_value_changed(value: float) -> void:
	random_pitch_value_label.text = "%10.2f" % value
	random_pitch_slider.value = value
	player.random_pitch = value


func _on_volume_value_changed(value: float) -> void:
	volume_value_label.text = "%10.2f" % value
	volume_slider.value = value
	player.volume_db = value


func _on_random_volume_offset_value_changed(value: float) -> void:
	random_volume_offset_value_label.text = "%10.2f" % value
	random_volume_offset_slider.value = value
	player.random_volume_offset_db = value


func _on_word_pause_value_changed(value: float) -> void:
	word_pause_value_label.text = "%10.2f" % value
	word_pause_slider.value = value
	player.word_pause = value


func _on_punctuation_pause_value_changed(value: float) -> void:
	punctuation_pause_value_label.text = "%10.2f" % value
	punctuation_pause_slider.value = value
	player.punctuation_pause = value


func _on_question_pitch_scale_value_changed(value: float) -> void:
	question_pitch_scale_value_label.text = "%10.2f" % value
	question_pitch_scale_slider.value = value
	player.question_pitch_scale = value


func _on_syllable_size_value_changed(value: float) -> void:
	syllable_size_value_label.text = "%d" % value
	syllable_size_slider.value = value
	player.syllable_size = value


func _on_randomize_settings_button_pressed() -> void:
	player.main_pitch_scale = randf_range(0.5, 2)
	player.random_pitch = randf_range(1.0, 2)
	player.random_volume_offset_db = randf_range(0, 5)
	player.word_pause = randf_range(0, 0.2)
	player.punctuation_pause = randf_range(0, 0.4)
	player.question_pitch_scale = randf_range(1, 2)
	player.volume_db = randf_range(-5, 5)
	_on_sound_option_button_item_selected(randi_range(0, file_option_button.item_count - 1))
	player.word_cutting_percentage = randi_range(0, 2) * 0.1
	
	player.generator_frequence_hz = randf_range(10, 8000)
	player.generator_frequence2_hz = randf_range(10, 8000)
	player.generator_length = randf_range(0.01, 0.5)
	player.generator_amplitude = randf_range(0.4, 0.6)
	player.generator_noise = randf_range(0, 0.3)
	player.generator_smooth_wave = randi_range(0, 10)
	_on_generator_type_option_button_item_selected(randi_range(0, VoiceAudioStreamPlayer.GENERATOR_TYPE.keys().size() - 1))
	
	alphabet_pitch_option_button.selected = randi_range(0, alphabet_pitch_option_button.item_count - 1)
	_on_sound_source_tab_container_tab_changed(randi_range(0, 2))
	
	refresh_ui()


func _on_sound_option_button_item_selected(index: int) -> void:
	file_option_button.selected = index
	var file_name := file_option_button.get_item_text(index)
	var sound := load("res://addons/godot-voice-generator/sound/" + file_name)
	if not sound:
		push_error("File not found %s" % file_name)
		return
	player.set_sub_stream(sound)


func _on_sound_source_tab_container_tab_changed(tab: int) -> void:
	player.source_type = tab
	match tab:
		VoiceAudioStreamPlayer.SOURCE_TYPE.FILE:
			_on_sound_option_button_item_selected(file_option_button.selected)
		VoiceAudioStreamPlayer.SOURCE_TYPE.GENERATOR:
			pass
		VoiceAudioStreamPlayer.SOURCE_TYPE.ALPHABET:
			update_alphabet_mapping()
	player.stop_saying()


func _on_generator_type_option_button_item_selected(index: int) -> void:
	player.generator_type = index
	player.refresh_generator_data()


func _on_generator_frequence_value_changed(value: float) -> void:
	generator_frequence_value_label.text = "%10.2f" % value
	generator_frequence_slider.value = value
	player.generator_frequence_hz = value
	player.refresh_generator_data()


func _on_generator_frequence2_value_changed(value: float) -> void:
	generator_frequence2_value_label.text = "%10.2f" % value
	generator_frequence2_slider.value = value
	player.generator_frequence2_hz = value
	player.refresh_generator_data()


func _on_generator_length_value_changed(value: float) -> void:
	generator_length_value_label.text = "%10.2f" % value
	generator_length_slider.value = value
	player.generator_length = value
	player.refresh_generator_data()


func _on_generator_amplitude_value_changed(value: float) -> void:
	generator_amplitude_value_label.text = "%10.2f" % value
	generator_amplitude_slider.value = value
	player.generator_amplitude = value
	player.refresh_generator_data()


func _on_generator_noise_value_changed(value: float) -> void:
	generator_noise_value_label.text = "%10.2f" % value
	generator_noise_slider.value = value
	player.generator_noise = value
	player.refresh_generator_data()


func _on_generator_smooth_value_changed(value: float) -> void:
	generator_smooth_iter_value_label.text = "%d" % value
	generator_smooth_iter_slider.value = value
	player.generator_smooth_wave = value
	player.refresh_generator_data()


func _on_word_cutting_value_changed(value: float) -> void:
	word_cutting_value_label.text = "%10.2f%%" % value
	word_cutting_slider.value = value
	player.word_cutting_percentage = value


func _on_alphabet_pitch_option_button_item_selected(index: int) -> void:
	update_alphabet_mapping()


func update_alphabet_mapping() -> void:
	if not alphabet_pitch_option_button.item_count:
		return
	var pitch := alphabet_pitch_option_button.get_item_text(alphabet_pitch_option_button.selected)
	player.alphabet_mapping = {
		"default": load("res://addons/godot-voice-generator/sound/alphabet/%s/a.wav" % pitch),
		"a": load("res://addons/godot-voice-generator/sound/alphabet/%s/a.wav" % pitch),
		"b": load("res://addons/godot-voice-generator/sound/alphabet/%s/b.wav" % pitch),
		"c": load("res://addons/godot-voice-generator/sound/alphabet/%s/c.wav" % pitch),
		"d": load("res://addons/godot-voice-generator/sound/alphabet/%s/d.wav" % pitch),
		"e": load("res://addons/godot-voice-generator/sound/alphabet/%s/e.wav" % pitch),
		"f": load("res://addons/godot-voice-generator/sound/alphabet/%s/f.wav" % pitch),
		"g": load("res://addons/godot-voice-generator/sound/alphabet/%s/g.wav" % pitch),
		"h": load("res://addons/godot-voice-generator/sound/alphabet/%s/h.wav" % pitch),
		"i": load("res://addons/godot-voice-generator/sound/alphabet/%s/i.wav" % pitch),
		"j": load("res://addons/godot-voice-generator/sound/alphabet/%s/j.wav" % pitch),
		"k": load("res://addons/godot-voice-generator/sound/alphabet/%s/k.wav" % pitch),
		"l": load("res://addons/godot-voice-generator/sound/alphabet/%s/l.wav" % pitch),
		"m": load("res://addons/godot-voice-generator/sound/alphabet/%s/m.wav" % pitch),
		"n": load("res://addons/godot-voice-generator/sound/alphabet/%s/n.wav" % pitch),
		"o": load("res://addons/godot-voice-generator/sound/alphabet/%s/o.wav" % pitch),
		"p": load("res://addons/godot-voice-generator/sound/alphabet/%s/p.wav" % pitch),
		"q": load("res://addons/godot-voice-generator/sound/alphabet/%s/q.wav" % pitch),
		"r": load("res://addons/godot-voice-generator/sound/alphabet/%s/r.wav" % pitch),
		"s": load("res://addons/godot-voice-generator/sound/alphabet/%s/s.wav" % pitch),
		"t": load("res://addons/godot-voice-generator/sound/alphabet/%s/t.wav" % pitch),
		"u": load("res://addons/godot-voice-generator/sound/alphabet/%s/u.wav" % pitch),
		"v": load("res://addons/godot-voice-generator/sound/alphabet/%s/v.wav" % pitch),
		"w": load("res://addons/godot-voice-generator/sound/alphabet/%s/w.wav" % pitch),
		"x": load("res://addons/godot-voice-generator/sound/alphabet/%s/x.wav" % pitch),
		"y": load("res://addons/godot-voice-generator/sound/alphabet/%s/y.wav" % pitch),
		"z": load("res://addons/godot-voice-generator/sound/alphabet/%s/z.wav" % pitch)
	}


func _on_stop_button_pressed() -> void:
	player.stop_saying()


func _on_preset_option_button_item_selected(index: int) -> void:
	match preset_option_button.get_item_id(index):
		Presets.FILE_SIMPLE_SOUND_V:
			player.main_pitch_scale = 1.1
			player.random_pitch = 0.2
			player.question_pitch_scale = 1.2
			player.volume_db = 0
			player.random_volume_offset_db = 3
			player.word_pause = 0.02
			player.punctuation_pause = 0.1
			player.syllable_size = 3
			player.word_cutting_percentage = 0
			_on_sound_option_button_item_selected(1)
			_on_sound_source_tab_container_tab_changed(0)
		Presets.FILE_SIMPLE_SOUND_V2:
			player.main_pitch_scale = 2.2
			player.random_pitch = 0.4
			player.question_pitch_scale = 1.2
			player.volume_db = 0
			player.random_volume_offset_db = 3
			player.word_pause = 0.02
			player.punctuation_pause = 0.1
			player.syllable_size = 5
			player.word_cutting_percentage = 0
			_on_sound_option_button_item_selected(17)
			_on_sound_source_tab_container_tab_changed(0)
		Presets.PULSE_GENERATOR:
			player.main_pitch_scale = 1
			player.random_pitch = 1
			player.question_pitch_scale = 1.3
			player.volume_db = 0
			player.random_volume_offset_db = 0
			player.word_pause = 0.02
			player.punctuation_pause = 0.1
			player.syllable_size = 3
			player.word_cutting_percentage = 0
			player.generator_type = VoiceAudioStreamPlayer.GENERATOR_TYPE.PULSE
			player.generator_frequence_hz = 2643
			player.generator_frequence2_hz = 1902
			player.generator_length = 0.2
			player.generator_amplitude = 0.5
			player.generator_noise = 1
			player.generator_smooth_wave = 3
			_on_sound_source_tab_container_tab_changed(1)
		Presets.SINE_GENERATOR:
			player.main_pitch_scale = 1
			player.random_pitch = 1
			player.question_pitch_scale = 1.3
			player.volume_db = 0
			player.random_volume_offset_db = 0
			player.word_pause = 0.02
			player.punctuation_pause = 0.1
			player.syllable_size = 3
			player.word_cutting_percentage = 0
			player.generator_type = VoiceAudioStreamPlayer.GENERATOR_TYPE.SINE
			player.generator_frequence_hz = 243
			player.generator_frequence2_hz = 666
			player.generator_length = 0.15
			player.generator_amplitude = 0.5
			player.generator_noise = 0
			player.generator_smooth_wave = 0
			_on_sound_source_tab_container_tab_changed(1)
		Presets.ANIMAL_ALPHABET:
			player.main_pitch_scale = 2.6
			player.random_pitch = 0.4
			player.question_pitch_scale = 1.2
			player.volume_db = 0
			player.random_volume_offset_db = 0
			player.word_pause = 0.02
			player.punctuation_pause = 0.1
			player.syllable_size = 5
			player.word_cutting_percentage = 0.3
			alphabet_pitch_option_button.selected = 1
			_on_sound_source_tab_container_tab_changed(2)
		Presets.GIRL_ALPHABET:
			player.main_pitch_scale = 2.2
			player.random_pitch = 1.0
			player.question_pitch_scale = 1.2
			player.volume_db = 0
			player.random_volume_offset_db = 0
			player.word_pause = 0.02
			player.punctuation_pause = 0.3
			player.syllable_size = 5
			player.word_cutting_percentage = 0	
			alphabet_pitch_option_button.selected = 0
			_on_sound_source_tab_container_tab_changed(2)
	
	refresh_ui()
