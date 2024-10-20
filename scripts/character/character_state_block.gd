# character_state_block.gd
class_name CharacterStateBlock
extends CharacterState


func _ready() -> void:
	state_name = "block"


func enter() -> void:
	super()
	character.velocity.x = 0
	character.velocity.y = 0
	character.play_anim("block", 0, -40)
