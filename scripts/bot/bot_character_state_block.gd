# bot_character_state_block.gd
class_name BotCharacterStateBlock
extends CharacterStateBlock


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func process_physics(delta: float) -> State:
	super(delta)
	if params.idle_only and params.always_block:
		return null
	if params.is_in_jump_distance() and character.is_on_floor():
		return state_jump
	elif params.is_in_attack_distance():
		if character.opponent.fsm.is_state("attack_startup") or character.opponent.fsm.is_state("attack_hit"):
			return null
		else:
			if randf() < 0.5:
				state_attack_startup.current_attack = character.attacks["attack1"]
			else:
				state_attack_startup.current_attack = character.attacks["attack2"]
			return state_attack_startup
			
	else:
		return state_walk
	return null
