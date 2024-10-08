# bot_character_state_idle.gd
class_name BotCharacterStateIdle
extends CharacterStateIdle


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func process_physics(delta: float) -> State:
	super(delta)
	if character.is_stunned:
		return state_stun
	if params.idle_only:
		if params.always_block:
			return state_block
		else:
			return null
	if params.is_in_jump_distance():
		return state_jump
	elif params.is_in_attack_distance():
		if character.opponent.fsm.current_state.state_name == "attack":
			return state_block
		else:
			return state_attack
	else:
		return state_walk
	return null
