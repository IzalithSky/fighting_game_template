extends Control

@onready var player1 = $VBoxContainer/HBoxContainer/VBoxContainer1/Player1Slot
@onready var player1bot = $VBoxContainer/HBoxContainer/VBoxContainer1/Player1Bot
@onready var player1bot_options = $Player1BotOptions
@onready var player1bot_idle = $Player1BotOptions/Player1IdleCheckBox
@onready var player1bot_block = $Player1BotOptions/Player1BlockCheckBox

@onready var player2 = $VBoxContainer/HBoxContainer/VBoxContainer2/Player2Slot
@onready var player2bot = $VBoxContainer/HBoxContainer/VBoxContainer2/Player2Bot
@onready var player2bot_options = $Player2BotOptions
@onready var player2bot_idle = $Player2BotOptions/Player2IdleCheckBox
@onready var player2bot_block = $Player2BotOptions/Player2BlockCheckBox

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
		world.fsm1_scene = load("res://scenes/bot_character_state_machine.tscn")
		var player1_always_idle = player1bot_idle.button_pressed
		var player1_always_block = player1bot_block.button_pressed
	else:
		world.fsm1_scene = load("res://scenes/player_character_state_machine.tscn")
	
	if (player2bot.button_pressed):
		world.fsm2_scene = load("res://scenes/bot_character_state_machine.tscn")
		var player2_always_idle = player2bot_idle.button_pressed
		var player2_always_block = player2bot_block.button_pressed
	else:
		world.fsm2_scene = load("res://scenes/player_character_state_machine.tscn")
	
	get_tree().get_root().add_child(world)
	get_tree().get_root().remove_child(self)

func on_player_1_bot_toggled(toggled_on: bool) -> void:
	player1bot_options.visible = toggled_on
	
func on_player_2_bot_toggled(toggled_on: bool) -> void:
	player2bot_options.visible = toggled_on
