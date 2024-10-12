extends Control

@export var player1: CharacterSlot
@export var player2: CharacterSlot

func _ready():
	player1.grab_focus()
	pass
