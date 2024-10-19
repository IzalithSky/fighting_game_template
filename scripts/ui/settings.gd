extends Control

@onready var back_button = $BackButton
@onready var player1_action_list = $ScrollContainer/MarginContainer/SettingsContainer/P1ActionList
@onready var player2_action_list = $ScrollContainer/MarginContainer/SettingsContainer/P2ActionList
@onready var fullscreen_checkbox = $ScrollContainer/MarginContainer/SettingsContainer/FullscreenContainer/FullscreenCheckBox
@onready var music_volume_slider = $ScrollContainer/MarginContainer/SettingsContainer/MusicContainer/MusicSlider
@onready var sfx_volume_slider = $ScrollContainer/MarginContainer/SettingsContainer/SFXContainer/SFXSlider

@onready var input_button_scene = preload("res://scenes/ui/settings_input_buttons.tscn")

var is_remapping = false
var action_to_remap = null
var event_to_remap = null
var remapping_button = null
var input_actions = {
	"left": "Move left",
	"right": "Move right",
	"jump": "Jump",
	"attack1": "Attack 1",
	"attack2": "Attack 2",
	"attack_ranged": "Attack ranged",
	"block": "Block",
}

func _ready():
	back_button.grab_focus()
	fullscreen_checkbox.button_pressed = ConfigHandler.load_settings("video").fullscreen
	var audio_settings = ConfigHandler.load_settings("audio")
	music_volume_slider.value = min(audio_settings.music_volume, 1.0) * 100
	sfx_volume_slider.value = min(audio_settings.sfx_volume, 1.0) * 100
	create_action_list()

func create_action_list():
	InputMap.load_from_project_settings()
	fill_action_list("p1_", player1_action_list)
	fill_action_list("p2_", player2_action_list)
	
func fill_action_list(prefix: String, action_list: Control):
	for item in action_list.get_children():
		item.queue_free()
	
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_button1 = button.find_child("Button1")
		var input_button2 = button.find_child("Button2")
		
		action_label.text = input_actions[action]
		var events = InputMap.action_get_events(prefix + action)
		var filtered_events = []
		for event in events:
			if !(event is InputEventJoypadButton or event is InputEventJoypadMotion):
				filtered_events.append(event)
		var event1 = null
		if filtered_events.size() > 0:
			event1 = filtered_events[0]
			input_button1.text = filtered_events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_button1.text = ""
		
		var event2 = null
		if filtered_events.size() > 1:
			event2 = filtered_events[1]
			input_button2.text = filtered_events[1].as_text().trim_suffix(" (Physical)")
		else:
			input_button2.text = ""
		action_list.add_child(button)
		input_button1.pressed.connect(on_input_button_pressed.bind(prefix + action, event1, input_button1))
		input_button2.pressed.connect(on_input_button_pressed.bind(prefix + action, event2, input_button2))
	
func on_input_button_pressed(action, event, clicked_button):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		event_to_remap = event
		remapping_button = clicked_button
		clicked_button.text = "Press key to bind.."
		
func _input(event: InputEvent):
	if is_remapping:
		if event is InputEventKey:
			if event.is_action_pressed("ui_cancel"):
				if event_to_remap == null:
					remapping_button.text = ""
				else: 
					remapping_button.text = event_to_remap.as_text().trim_suffix(" (Physical)")
			else:
				InputMap.action_erase_event(action_to_remap, event_to_remap)
				InputMap.action_add_event(action_to_remap, event)
				remapping_button.text = event.as_text().trim_suffix(" (Physical)")
			
			is_remapping = false
			action_to_remap = null
			event_to_remap = null
			remapping_button = null
			accept_event()
			
	elif event.is_action_pressed("ui_cancel"):
		close_scene()
	

func _on_back_button_pressed():
	close_scene()

func close_scene():
	queue_free() 

func on_reset_button_pressed():
	create_action_list()


func on_fullscreen_check_box_toggled(toggled_on: bool):
	ConfigHandler.save_setting("video", "fullscreen", toggled_on)
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func on_music_slider_drag_ended(value_changed: bool):
	if value_changed:
		ConfigHandler.save_setting("audio", "music_volume", music_volume_slider.value / 100)

func on_sfx_slider_drag_ended(value_changed: bool):
	if value_changed:
		ConfigHandler.save_setting("audio", "sfx_volume", sfx_volume_slider.value / 100)
