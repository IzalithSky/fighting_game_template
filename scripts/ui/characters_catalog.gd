# characters_catalog.gd
extends Control

signal character_selected(selected_character: Dictionary)

@export var character_slot_scene: PackedScene
@onready var character_grid = $GridContainer

var player_number: int = 0
var current_character: Dictionary

func set_player_data(player: int, selected_character: Dictionary):
	player_number = player
	current_character = selected_character
	show_current_character()

func _ready():
	#self.grab_focus()
	var characters = CharactersList.get_all_characters()
	populate_character_grid(characters)

func populate_character_grid(characters: Array):
	var grid_width = character_grid.size.x
	var columns = character_grid.columns
	var slot_width = grid_width / columns
	
	for character_data in characters:
		var character_slot = character_slot_scene.instantiate()
		character_slot.custom_minimum_size = Vector2(slot_width, slot_width) # 200 is just an example height, adjust as needed
		character_slot.assign_character(character_data)
		character_grid.add_child(character_slot)
		character_slot.connect("gui_input", Callable(self, "on_character_slot_click").bind(character_data))
		if (character_data["scene_path"] == current_character["scene_path"]):
			character_slot.grab_focus()
		
func on_character_slot_click(event: InputEvent, selected_character: Dictionary):
	if event is InputEventMouseButton and event.pressed:
		on_character_selected(selected_character)
			
	if event is InputEventKey and (event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept")):
		on_character_selected(selected_character)
	
func on_character_selected(selected_character: Dictionary):
	emit_signal("character_selected", selected_character)
	close_library()
	
func show_current_character():
	$TitleLabel.text = "Choose Player " + str(player_number)

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		close_library()

func _on_back_button_pressed() -> void:
	close_library()

func close_library():
	queue_free() 
