# character_state_machine.gd
class_name CharacterStateMachine
extends StateMachine


func set_character(character: Character):
	for child in get_children():
		if child is CharacterState or child is BotParameters:
			child.character = character


func apply_stun(duration: float) -> void:
	var new_state: CharacterState = current_state.apply_stun(duration)
	if new_state:
		change_state(new_state)
