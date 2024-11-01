# bot_character_state_idle.gd
class_name BotCharacterStateIdle
extends CharacterStateIdle


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func process_physics(delta: float) -> State:
	super(delta)
	
	var opponent_can_reach = params.opponent_can_reach()
	
	if params.projectile_warning == params.ProjectileWarning.WARNING and not opponent_can_reach:
		if character.jumps_left > 0:
			return state_jump
		else:
			return state_block

	if params.projectile_warning == params.ProjectileWarning.IMMINENT:
		return state_block
		
	if params.rng() < 0.5 and character.opponent.fsm.is_state("jump"):
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

	if opponent_can_reach and not character.opponent.fsm.is_recovery():
		return state_block

	if params.rng() < 0.8 and not character.opponent.is_invincible:
		if params.is_enemy_in_attack_range("attack1"):
			state_attack.current_attack = character.attacks["attack1"]
			return state_attack
		if params.is_enemy_in_attack_range("attack2"):
			state_attack.current_attack = character.attacks["attack2"]
			return state_attack
		
	if (character.opponent.fsm.is_state("block") or character.opponent.is_invincible) and character.is_on_floor():
		return state_walk

	if params.is_opponent_above() and character.jumps_left > 0:
		return state_jump
		
	var r = params.rng()
	if r < 0.1 and character.jumps_left > 0:
		return state_jump
	elif r < 0.2:
		return state_block

	return state_walk
