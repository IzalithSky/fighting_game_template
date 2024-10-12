extends Control

@export var player1: CharacterSlot
@export var player2: CharacterSlot

func _ready():
	player1.grab_focus()
	
	var characters = CharactersList.get_all_characters()
	player1.assign_character(characters[0])
	player2.assign_character(characters[1])
