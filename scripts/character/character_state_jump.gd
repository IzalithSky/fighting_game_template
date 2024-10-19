# character_state_jump.gd
class_name CharacterStateJump
extends CharacterState


func _ready() -> void:
	state_name = "jump"


func enter() -> void:
	super()
	character.jumps_left -= 1
