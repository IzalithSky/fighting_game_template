# bot_character_state_block.gd
class_name BotCharacterStateBlock
extends CharacterStateBlock


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func enter():
	super()
	params.current_block_time = params.block_duration


func process_physics(delta: float) -> State:
	super(delta)
	
	if params.current_block_time > 0:
		params.current_block_time -= delta
		return null
	
	if params.is_in_jump_distance() and character.is_on_floor():
		return state_jump
	
	if params.opponent_can_reach() and not character.opponent.fsm.is_recovery():
		return null

	if params.can_reach_opponent():
		if randf() < 0.5:
			state_attack.current_attack = character.attacks["attack1"]
		else:
			state_attack.current_attack = character.attacks["attack2"]
		return state_attack
	else:
		return state_walk
	
	return null
