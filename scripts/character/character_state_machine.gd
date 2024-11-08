# character_state_machine.gd
class_name CharacterStateMachine
extends StateMachine


signal priority_action()


func set_character(character: Character):
	for child in get_children():
		if child is CharacterState or child is BotParameters:
			child.character = character


func apply_stun(duration: float) -> void:
	var new_state: CharacterState = current_state.apply_stun(duration)
	if new_state:
		change_state(new_state)


func start_intro() -> void:
	var new_state: CharacterState = current_state.start_intro()
	if new_state:
		change_state(new_state)


func start_round() -> void:
	var new_state: CharacterState = current_state.start_round()
	if new_state:
		change_state(new_state)


func end_round() -> void:
	var new_state: CharacterState = current_state.end_round()
	if new_state:
		change_state(new_state)


func is_startup() -> bool:
	if not is_state("attack"):
		return false
	return (current_state as CharacterStateAttack).current_attack.is_startup


func is_recovery() -> bool:
	if not is_state("attack"):
		return false
	return (current_state as CharacterStateAttack).current_attack.is_recovery


func get_current_attack_name() -> String:
	if not is_state("attack"):
		return ""
	else:
		return (current_state as CharacterStateAttack).current_attack.name	
