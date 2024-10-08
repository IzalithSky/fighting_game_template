# character_state_attack.gd
class_name CharacterStateAttack
extends CharacterState


func _ready() -> void:
	state_name = "attack"


func enter() -> void:
	super()
	character.is_attacking = true


func process_frame(delta: float) -> State:
	super(delta)
	if character.is_stunned:
		return state_stun
	if not character.is_attacking:
		character.disable_hitboxes()
		return state_idle
	return null
