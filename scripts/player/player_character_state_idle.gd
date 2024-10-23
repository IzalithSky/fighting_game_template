# player_character_state_idle.gd
class_name PlayerCharacterStateIdle
extends CharacterStateIdle


func process_physics(delta: float) -> State:
	super(delta)
	if Input.is_action_just_pressed(character.input_prefix + "jump") and (character.is_on_floor() or character.jumps_left > 0):
		return state_jump
	elif Input.is_action_pressed(character.input_prefix + "left") or Input.is_action_pressed(character.input_prefix + "right"):
		return state_walk
	elif Input.is_action_pressed(character.input_prefix + "block"):
		return state_block
	return null	


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
