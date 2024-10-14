# bot_character_state_idle.gd
class_name BotCharacterStateIdle
extends CharacterStateIdle


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func process_physics(delta: float) -> State:
	super(delta)
	if params.idle_only:
		if params.always_block:
			return state_block
		else:
			return null
	if params.is_in_jump_distance() and character.is_on_floor():
		if randf() < 0.5:
			return state_jump
		else:
			state_attack_startup.current_attack = character.attacks["attack_ranged"]
			return state_attack_startup
	elif params.is_in_attack_distance():
		if character.opponent.fsm.is_state("attack_startup") or character.opponent.fsm.is_state("attack_hit"):
			return state_block
		else:
			if randf() < 0.5:
				state_attack_startup.current_attack = character.attacks["attack1"]
			else:
				state_attack_startup.current_attack = character.attacks["attack2"]
			return state_attack_startup
	else:
		if randf() > 0.95 and character.is_on_floor() and not params.is_in_attack_distance():
			state_attack_startup.current_attack = character.attacks["attack_ranged"]
			return state_attack_startup
		else:
			return state_walk
	return null
