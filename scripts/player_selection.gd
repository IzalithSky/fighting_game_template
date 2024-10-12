extends Control

@export var player1: CharacterSlot
@export var player2: CharacterSlot
@export var character_library_scene: PackedScene = preload("res://scenes/characters_catalog.tscn")

var player1character: Dictionary
var player2character: Dictionary

func _ready():
	player1.connect("gui_input", Callable(self, "on_character_slot_click").bind(player1))
	player2.connect("gui_input", Callable(self, "on_character_slot_click").bind(player2))
	
	var characters = CharactersList.get_all_characters()
	player1character = characters[0]
	player2character = characters[1]
	
	refresh_character_slots()
	player1.grab_focus()

func refresh_character_slots():
	player1.assign_character(player1character)
	player2.assign_character(player2character)
	
func on_character_slot_click(event: InputEvent, slot: CharacterSlot):
	if event is InputEventMouseButton and event.pressed:
		open_character_library(slot)
			
	if event is InputEventKey and (event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept")):
		open_character_library(slot)

func open_character_library(slot: CharacterSlot):
	var character_library = character_library_scene.instantiate()
	if (slot == player1):
		character_library.set_player_data(1, player1character)
	else:
		character_library.set_player_data(2, player2character)
	
	add_child(character_library)
	character_library.connect("character_selected", Callable(self, "on_character_selected").bind(slot))

func on_character_selected(selected_character: Dictionary, slot: CharacterSlot):
	slot.assign_character(selected_character)
	if slot == player1:
		player1character = selected_character
	elif slot == player2:
		player2character = selected_character
	slot.grab_focus()
	refresh_character_slots()
