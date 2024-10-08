# player_character_state_idle.gd
class_name PlayerCharacterStateIdle
extends CharacterStateIdle


func process_frame(delta: float) -> State:
	super(delta)
	if character.is_stunned:
		return state_stun
	if Input.is_action_pressed(character.input_prefix + "attack1") or Input.is_action_pressed(character.input_prefix + "attack2"):
		return state_attack
	if Input.is_action_pressed(character.input_prefix + "jump") and character.is_on_floor():
		return state_jump
	if Input.is_action_pressed(character.input_prefix + "left") or Input.is_action_pressed(character.input_prefix + "right"):
		return state_walk
	if Input.is_action_pressed(character.input_prefix + "block"):
		return state_block
	return null	
