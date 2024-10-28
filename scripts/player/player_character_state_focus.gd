# player_character_state_focus.gd
class_name PlayerCharacterStateFocus
extends CharacterStateFocus


func process_physics(delta: float) -> State:
	super(delta)
	if not Input.is_action_pressed(character.input_prefix + "focus"):
		return state_idle
	return null
