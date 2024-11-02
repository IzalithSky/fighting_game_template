# player_selection.gd
extends Control


@export var items_library_scene: PackedScene
@export var settings_scene: PackedScene

@onready var player1 = $VBoxContainer/HBoxContainer/VBoxContainer1/Player1Slot
@onready var player1bot = $VBoxContainer/HBoxContainer/VBoxContainer1/Player1Bot

@onready var player2 = $VBoxContainer/HBoxContainer/VBoxContainer2/Player2Slot
@onready var player2bot = $VBoxContainer/HBoxContainer/VBoxContainer2/Player2Bot

@onready var stage_selector = $HBoxContainer/VBoxContainer/VBoxContainer/StageSelectionSlot
@onready var rounds_picker = $HBoxContainer/VBoxContainer2/RoundsNumberPicker
@onready var round_timer_picker = $HBoxContainer/VBoxContainer3/TimerNumberPicker

var player1character: Dictionary
var player2character: Dictionary
var current_stage: Dictionary


func _ready():
	player1.connect("gui_input", Callable(self, "on_character_slot_click").bind(player1))
	player2.connect("gui_input", Callable(self, "on_character_slot_click").bind(player2))
	stage_selector.connect("gui_input", Callable(self, "on_level_slot_click").bind(stage_selector))
	var characters = CharactersList.get_all_characters()
	player1character = characters[0]
	player2character = characters[1]
	
	refresh_character_slots()
	player1.grab_focus()
	player2bot.button_pressed = true

	current_stage = CharactersList.get_all_levels()[0]
	stage_selector.assign_character(current_stage)

func refresh_character_slots():
	player1.assign_character(player1character)
	player2.assign_character(player2character)


func on_character_slot_click(event: InputEvent, slot: CharacterSlot):
	if event is InputEventMouseButton and event.pressed:
		open_character_library(slot)
			
	if event is InputEventKey and (event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept")):
		open_character_library(slot)


func open_character_library(slot: CharacterSlot):
	var character_library = items_library_scene.instantiate()
	if (slot == player1):
		character_library.set_library_data("Choose Player 1", CharactersList.get_all_characters(), player1character)
	else:
		character_library.set_library_data("Choose Player 2", CharactersList.get_all_characters(), player2character)
	
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

func on_level_slot_click(event: InputEvent, slot: CharacterSlot):
	if event is InputEventMouseButton and event.pressed:
		open_levels_library()
			
	if event is InputEventKey and (event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept")):
		open_levels_library()

func open_levels_library():
	var character_library = items_library_scene.instantiate()
	character_library.set_library_data("Choose Stage", CharactersList.get_all_levels(), current_stage)
	add_child(character_library)
	character_library.connect("character_selected", Callable(self, "on_stage_selected").bind(stage_selector))

func on_stage_selected(selected_level: Dictionary, slot: CharacterSlot):
	slot.assign_character(selected_level)
	slot.grab_focus()
	current_stage = selected_level
	
func on_play_button_pressed() -> void:
	var world_scene = preload("res://scenes/world.tscn")
	var world = world_scene.instantiate()
	world.player1_scene = load(player1character["scene_path"])
	world.player1name = player1character["name"]
	world.player2_scene = load(player2character["scene_path"])
	world.player2name = player2character["name"]
	if player1character["name"] == player2character["name"]:
		world.player1name = player1character["name"] + " 1"
		world.player2name = player1character["name"] + " 2"
		
	if (player1bot.button_pressed):
		world.fsm1_scene = load("res://scenes/characters/bot_character_state_machine.tscn")
	else:
		world.fsm1_scene = load("res://scenes/characters/player_character_state_machine.tscn")
	
	if (player2bot.button_pressed):
		world.fsm2_scene = load("res://scenes/characters/bot_character_state_machine.tscn")
	else:
		world.fsm2_scene = load("res://scenes/characters/player_character_state_machine.tscn")
		
	world.background_scene = load(current_stage["scene_path"])
	var rounds = rounds_picker.get_selected_value_as_number()
	world.total_rounds = rounds
	var round_time_sec = round_timer_picker.get_selected_value_as_number()
	world.round_time_limit = round_time_sec if round_time_sec != 0 else 60
	get_tree().get_root().add_child(world)
	get_tree().get_root().remove_child(self)


func on_settings_button_pressed() -> void:
	var settings = settings_scene.instantiate()
	add_child(settings)
