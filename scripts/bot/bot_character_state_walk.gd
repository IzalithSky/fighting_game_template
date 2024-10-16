# bot_character_state_walk.gd
class_name BotCharacterStateWalk
extends CharacterStateWalk


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func process_physics(delta: float) -> State:
	super(delta)
	
	if params.projectile_warning == params.ProjectileWarning.WARNING:
		return state_jump

	if params.projectile_warning == params.ProjectileWarning.IMMINENT:
		return state_block

	if params.is_in_jump_distance() and character.is_on_floor():
		var r = randf()
		if r < 0.33:
			return state_jump
		if r < 0.66:
			return state_walk
		state_attack_startup.current_attack = character.attacks["attack_ranged"]
		return state_attack_startup

	if character.opponent.fsm.is_state("block"):
		if not params.is_in_ranged_distance():
			var r = randf()
			if r < 0.8:
				do_move(-get_dir_towards_opponent())
				return null
			elif r < 0.9:
				state_attack_startup.current_attack = character.attacks["attack_ranged"]
				return state_attack_startup
			else:
				if randf() < 0.5:
					state_attack_startup.current_attack = character.attacks["attack1"]
				else:
					state_attack_startup.current_attack = character.attacks["attack2"]
				return state_attack_startup
		else:
			state_attack_startup.current_attack = character.attacks["attack_ranged"]
			return state_attack_startup

	if params.is_in_attack_distance():
		if character.opponent.fsm.is_state("attack_startup") or character.opponent.fsm.is_state("attack_hit"):
			return state_block
		if randf() < 0.75:
			if randf() < 0.5:
				state_attack_startup.current_attack = character.attacks["attack1"]
			else:
				state_attack_startup.current_attack = character.attacks["attack2"]
			return state_attack_startup
		if randf() < 0.5:
			return state_jump
		else:
			return state_block

	if randf() < 0.95:
		do_move(get_dir_towards_opponent())
		return null
	else:
		return state_jump


func get_dir_towards_opponent() -> float:
	if character.position.x < character.opponent.position.x:
		return 1
	else:
		return -1
