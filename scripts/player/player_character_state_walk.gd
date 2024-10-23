# player_character_state_walk.gd
class_name PlayerCharacterStateWalk
extends CharacterStateWalk


func process_physics(delta: float) -> State:
	super(delta)
	if character.fsm.is_state("block"):
		return state_stun
	elif Input.is_action_just_pressed(character.input_prefix + "jump") and (character.is_on_floor() or character.jumps_left > 0):
		return state_jump
	elif Input.is_action_pressed(character.input_prefix + "block"):
		return state_block
	elif Input.is_action_pressed(character.input_prefix + "left") or Input.is_action_pressed(character.input_prefix + "right"):
		do_move(get_move_dir())
		return null
	else:
		return state_idle


func process_input(event: InputEvent) -> State:	
	if event.is_action_pressed(character.input_prefix + "attack1"):
		state_attack.current_attack = character.attacks["attack1"]
		return state_attack
	elif event.is_action_pressed(character.input_prefix + "attack2"):
		state_attack.current_attack = character.attacks["attack2"]
		return state_attack
	elif event.is_action_pressed(character.input_prefix + "attack_ranged"):
		state_attack.current_attack = character.attacks["attack_ranged"]
		return state_attack
	elif event.is_action_pressed(character.input_prefix + "attack_special1"):
		state_attack.current_attack = character.attacks["attack_special1"]
		return state_attack
	elif event.is_action_pressed(character.input_prefix + "attack_special3"):
		state_attack.current_attack = character.attacks["attack_special3"]
		return state_attack
	return null


func get_move_dir() -> float:
	return Input.get_axis(character.input_prefix + "left", character.input_prefix + "right")
