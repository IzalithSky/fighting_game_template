# bot_character_state_walk.gd
class_name BotCharacterStateWalk
extends CharacterStateWalk


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
			do_move(get_dir_towards_opponent())
			return null
		state_attack.current_attack = character.attacks["attack_ranged"]
		return state_attack

	if character.opponent.fsm.is_state("block") or character.opponent.is_invincible:
		if not params.is_in_ranged_distance():
			var r = params.rng()
			if r < 0.1 and not character.opponent.is_invincible:
				if randf() < 0.5:
					state_attack.current_attack = character.attacks["attack1"]
				else:
					state_attack.current_attack = character.attacks["attack2"]
				return state_attack
			elif r < 0.2:
				state_attack.current_attack = character.attacks["attack_ranged"]
				return state_attack
			else:
				do_move(-get_dir_towards_opponent())
				return null

		else:
			state_attack.current_attack = character.attacks["attack_ranged"]
			return state_attack

	if params.is_in_attack_distance():
		if character.opponent.fsm.is_state("attack") and not character.opponent.fsm.is_recovery():
			return state_block
			
		if params.is_opponent_above() and character.jumps_left > 0:
			return state_jump
			
		if params.rng() < 0.75 and not character.opponent.is_invincible:
			if randf() < 0.5:
				state_attack.current_attack = character.attacks["attack1"]
			else:
				state_attack.current_attack = character.attacks["attack2"]
			return state_attack
		if params.rng() < 0.5 and character.jumps_left > 0:
			return state_jump
		else:
			return state_block

	if params.rng() < 0.95:
		do_move(get_dir_towards_opponent())
		return null
	elif character.jumps_left > 0:
		return state_jump
		
	return null


func get_dir_towards_opponent() -> float:
	if character.position.x < character.opponent.position.x:
		return 1
	else:
		return -1
