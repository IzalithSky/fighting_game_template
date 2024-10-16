# bot_character_state_idle.gd
class_name BotCharacterStateIdle
extends CharacterStateIdle


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func process_physics(delta: float) -> State:
	super(delta)
	
	if params.projectile_warning == params.ProjectileWarning.WARNING:
		return state_jump

	if params.projectile_warning == params.ProjectileWarning.IMMINENT:
		return state_block

	if params.is_in_jump_distance() and character.is_on_floor():
		if randf() < 0.5:
			return state_jump
		state_attack_startup.current_attack = character.attacks["attack_ranged"]
		return state_attack_startup

	if params.is_in_attack_distance():
		if character.opponent.fsm.is_state("attack_startup") or character.opponent.fsm.is_state("attack_hit"):
			return state_block

		if character.opponent.fsm.is_state("block") and character.is_on_floor():
			return state_walk

		if randf() < 0.75:
			if randf() < 0.5:
				state_attack_startup.current_attack = character.attacks["attack1"]
			else:
				state_attack_startup.current_attack = character.attacks["attack2"]
			return state_attack_startup

		return state_block

	if randf() > 0.95 and character.is_on_floor() and not params.is_in_attack_distance():
		state_attack_startup.current_attack = character.attacks["attack_ranged"]
		return state_attack_startup

	return state_walk
