# player_character_state_block.gd
class_name PlayerCharacterStateBlock
extends CharacterStateBlock


func process_input(event: InputEvent) -> State:
	if event.is_action_released(character.input_prefix + "block"):
		character.is_blocking = false
		return state_idle
	return null
