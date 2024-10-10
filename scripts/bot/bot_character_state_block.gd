# bot_character_state_block.gd
class_name BotCharacterStateBlock
extends CharacterStateBlock


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func process_physics(delta: float) -> State:
	super(delta)
	if params.idle_only and params.always_block:
		return null
	if params.is_in_jump_distance():
		return state_jump
	elif params.is_in_attack_distance():
		if character.opponent.fsm.current_state.state_name == "attack":
			return null
		else:
			return state_attack
	else:
		return state_walk
	return null