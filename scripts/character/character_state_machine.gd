# character_state_machine.gd
class_name CharacterStateMachine
extends StateMachine


func apply_stun(duration: float) -> void:
	var new_state: CharacterState = current_state.apply_stun(duration)
	if new_state:
		change_state(new_state)
