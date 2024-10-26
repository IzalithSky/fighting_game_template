# player_selection.gd
extends Control


@export var character_library_scene: PackedScene
@export var settings_scene: PackedScene

@onready var player1 = $VBoxContainer/HBoxContainer/VBoxContainer1/Player1Slot
@onready var player1bot = $VBoxContainer/HBoxContainer/VBoxContainer1/Player1Bot

@onready var player2 = $VBoxContainer/HBoxContainer/VBoxContainer2/Player2Slot
@onready var player2bot = $VBoxContainer/HBoxContainer/VBoxContainer2/Player2Bot

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
	player2bot.button_pressed = true


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


func on_play_button_pressed() -> void:
	var world_scene = preload("res://scenes/world.tscn")
	var world = world_scene.instantiate()
	world.player1_scene = load(player1character["scene_path"])
	world.player2_scene = load(player2character["scene_path"])
	
	if (player1bot.button_pressed):
		world.fsm1_scene = load("res://scenes/characters/bot_character_state_machine.tscn")
	else:
		world.fsm1_scene = load("res://scenes/characters/player_character_state_machine.tscn")
	
	if (player2bot.button_pressed):
		world.fsm2_scene = load("res://scenes/characters/bot_character_state_machine.tscn")
	else:
		world.fsm2_scene = load("res://scenes/characters/player_character_state_machine.tscn")
		
	world.background_scene = load("res://scenes/levels/dungeon_background.tscn")
	get_tree().get_root().add_child(world)
	get_tree().get_root().remove_child(self)


func on_settings_button_pressed() -> void:
	var settings = settings_scene.instantiate()
	add_child(settings)
