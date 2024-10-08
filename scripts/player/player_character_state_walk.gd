# player_character_state_walk.gd
class_name PlayerCharacterStateWalk
extends CharacterStateWalk


func process_frame(delta: float) -> State:
	super(delta)
	if character.is_stunned:
		return state_stun
	if Input.is_action_pressed(character.input_prefix + "attack1") or Input.is_action_pressed(character.input_prefix + "attack2"):
		return state_attack
	if Input.is_action_pressed(character.input_prefix + "jump") and character.is_on_floor():
		return state_jump
	if Input.is_action_pressed(character.input_prefix + "block"):
		return state_block
	return null


func process_physics(delta: float) -> State:
	super(delta)
	if Input.is_action_pressed(character.input_prefix + "left") or Input.is_action_pressed(character.input_prefix + "right"):
		do_move(get_move_dir())
	else:
		return state_idle
	return null


func get_move_dir() -> float:
	return Input.get_axis(character.input_prefix + "left", character.input_prefix + "right")
