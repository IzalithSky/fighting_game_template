# character_state_block.gd
class_name CharacterStateBlock
extends CharacterState


func _ready() -> void:
	state_name = "block"


func enter() -> void:
	super()
	character.is_blocking = true
	character.velocity.x = 0
	character.velocity.y = 0
	character.anim.play("block")


func process_frame(delta: float) -> State:
	super(delta)
	if character.is_stunned:
		return state_stun
	return null
