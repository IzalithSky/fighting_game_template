# bot_character_state_idle.gd
class_name BotCharacterStateIdle
extends CharacterStateIdle


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func process_physics(delta: float) -> State:
	super(delta)
	
	if params.projectile_warning == params.ProjectileWarning.WARNING and not params.is_in_attack_distance():
		if character.jumps_left > 0:
			return state_jump
		else:
			return state_block

	if params.projectile_warning == params.ProjectileWarning.IMMINENT:
		return state_block
		
	if not params.is_in_attack_distance() and character.opponent.fsm.is_state("jump"):
		state_attack.current_attack = character.attacks["attack_ranged"]
		return state_attack

	if params.is_in_jump_distance() and character.is_on_floor():
		var r = params.rng()
		if r < 0.15 and character.jumps_left > 0:
			return state_jump
		if r < 0.85:
			return state_walk
		state_attack.current_attack = character.attacks["attack_ranged"]
		return state_attack

	if params.is_in_attack_distance():
		if character.opponent.fsm.is_state("attack"):
			return state_block

		if (character.opponent.fsm.is_state("block") or character.opponent.is_invincible) and character.is_on_floor():
			return state_walk

		if params.is_opponent_above() and character.jumps_left > 0:
			return state_jump

		if params.rng() < 0.95 and not character.opponent.is_invincible:
			if randf() < 0.5:
				state_attack.current_attack = character.attacks["attack1"]
			else:
				state_attack.current_attack = character.attacks["attack2"]
			return state_attack
			
		if params.rng() < 0.5 and character.jumps_left > 0:
			return state_jump
		else:
			return state_block

	return state_walk
