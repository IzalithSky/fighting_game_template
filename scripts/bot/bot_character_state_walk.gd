# bot_character_state_walk.gd
class_name BotCharacterStateWalk
extends CharacterStateWalk


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func process_physics(delta: float) -> State:
	super(delta)
	if params.is_in_jump_distance():
		return state_jump
	elif params.is_in_attack_distance():
		if character.opponent.fsm.current_state.state_name == "attack":
			return state_block
		else:
			return state_attack
	else:
		do_move(get_move_dir())
	return null


func get_move_dir() -> float:
	if character.position.x < character.opponent.position.x:
		return 1
	else:
		return -1
