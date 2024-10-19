extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings_t.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("keybindings", "p1_left", "A")
		config.set_value("keybindings", "p1_right", "D")
		config.set_value("keybindings", "p1_jump", "W")
		config.set_value("keybindings", "p1_attack1", "C") #Kp 1
		config.set_value("keybindings", "p1_attack2", "V") #Kp 2
		config.set_value("keybindings", "p1_attack_ranged", "E") #Kp 4
		config.set_value("keybindings", "p1_block", "F") #Kp 3

		config.set_value("keybindings", "p2_left", "K")
		config.set_value("keybindings", "p2_right", ";")
		config.set_value("keybindings", "p2_jump", "O")
		config.set_value("keybindings", "p2_attack1", "M") 
		config.set_value("keybindings", "p2_attack2", "N")
		config.set_value("keybindings", "p2_attack_ranged", "J") 
		config.set_value("keybindings", "p2_block", "I") 
		
		config.set_value("video", "fullscreen", true) 
		
		config.set_value("audio", "music_volume", 1.0) 
		config.set_value("audio", "sfx_volume", 1.0) 
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)
	var fullscreen = load_settings("video").fullscreen
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func save_setting(section: String, key: String, value):
	config.set_value(section, key, value)
	config.save(SETTINGS_FILE_PATH)

func load_settings(section: String):
	var video_settings = {}
	for key in config.get_section_keys (section):
		video_settings[key] = config.get_value(section, key)
	return video_settings
	
