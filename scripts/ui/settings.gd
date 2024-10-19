extends Control

@onready var back_button = $BackButton
@onready var player1_action_list = $ScrollContainer/MarginContainer/SettingsContainer/P1ActionList
@onready var player2_action_list = $ScrollContainer/MarginContainer/SettingsContainer/P2ActionList
@onready var input_button_scene = preload("res://scenes/ui/settings_input_buttons.tscn")

var is_remapping = false
var action_to_remap = null
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
				
		if filtered_events.size() > 0:
			input_button1.text = filtered_events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_button1.text = ""
		if filtered_events.size() > 1:
			input_button2.text = filtered_events[1].as_text().trim_suffix(" (Physical)")
		else:
			input_button2.text = ""
		action_list.add_child(button)
	
func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		close_scene()

func _on_back_button_pressed() -> void:
	close_scene()

func close_scene():
	queue_free() 
