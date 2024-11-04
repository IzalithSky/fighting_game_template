# bot_character_state_walk.gd
class_name BotCharacterStateWalk
extends CharacterStateWalk


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

	if opponent_can_reach and not character.opponent.fsm.is_recovery():
		return state_block

	if character.opponent.fsm.is_state("knockdown_fall"):
		do_move(-get_dir_towards_opponent())
		return null
		
	if character.opponent.fsm.is_state("knockdown_down"):
		return state_focus

	if params.rng() < 0.5 and character.opponent.fsm.is_state("jump"):
		state_attack.current_attack = character.attacks["attack_ranged"]
		return state_attack

	if params.is_in_jump_distance() and character.is_on_floor():
		var r = params.rng()
		if r < 0.15 and character.jumps_left > 0:
			return state_jump
		if r < 0.4:
			do_move(-get_dir_towards_opponent())
			return null
		if r < 0.65:
			do_move(get_dir_towards_opponent())
			return null
		if r < 0.85:
			return state_focus
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

	if params.rng() < 0.75 and not character.opponent.is_invincible:
		if has_mp_for_attack("attack_special1") and params.is_enemy_in_attack_range("attack_special1"):
			state_attack.current_attack = character.attacks["attack_special1"]
			return state_attack
		if has_mp_for_attack("attack_special2") and params.is_enemy_in_attack_range("attack_special2"):
			state_attack.current_attack = character.attacks["attack_special2"]
			return state_attack
		if has_mp_for_attack("attack_special3") and params.is_enemy_in_attack_range("attack_special3"):
			state_attack.current_attack = character.attacks["attack_special3"]
			return state_attack
		if has_mp_for_attack("attack_special4") and params.is_enemy_in_attack_range("attack_special4"):
			state_attack.current_attack = character.attacks["attack_special4"]
			return state_attack
		if params.is_enemy_in_attack_range("attack1"):
			state_attack.current_attack = character.attacks["attack1"]
			return state_attack
		if params.is_enemy_in_attack_range("attack2"):
			state_attack.current_attack = character.attacks["attack2"]
			return state_attack
	
	if params.is_opponent_above() and character.jumps_left > 0:
		return state_jump
		
	var r = params.rng()
	if r < 0.1 and character.jumps_left > 0:
		return state_jump
	elif r < 0.2:
		return state_block
	
	if params.rng() < 0.5:
		do_move(get_dir_towards_opponent())
	else:
		do_move(-get_dir_towards_opponent())
		
	return null


func get_dir_towards_opponent() -> float:
	if character.position.x < character.opponent.position.x:
		return 1
	else:
		return -1
