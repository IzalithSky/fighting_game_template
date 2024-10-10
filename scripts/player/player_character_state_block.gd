# player_character_state_block.gd
class_name PlayerCharacterStateBlock
extends CharacterStateBlock


func process_physics(delta: float) -> State:
	super(delta)
	if not Input.is_action_pressed(character.input_prefix + "block"):
		character.fsm.is_state("block")
		return state_idle
	return null
