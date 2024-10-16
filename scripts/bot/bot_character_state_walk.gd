# bot_character_state_walk.gd
class_name BotCharacterStateWalk
extends CharacterStateWalk


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func process_physics(delta: float) -> State:
	super(delta)
	if params.projectile_warning == params.ProjectileWarning.WARNING:
		return state_jump
	elif params.projectile_warning == params.ProjectileWarning.IMMINENT:
		return state_block
	if params.is_in_jump_distance() and character.is_on_floor():
		var r = randf()
		if r < 0.33:
			return state_jump
		elif r < 0.66:
			return state_walk
		else:
			state_attack_startup.current_attack = character.attacks["attack_ranged"]
			return state_attack_startup
	elif params.is_in_attack_distance():
		if character.opponent.fsm.is_state("attack_startup") or character.opponent.fsm.is_state("attack_hit"):
			return state_block
		else:
			if character.opponent.fsm.is_state("block") and character.is_on_floor():
				return state_jump
			else:
				if randf() < 0.5:
					state_attack_startup.current_attack = character.attacks["attack1"]
				else:
					state_attack_startup.current_attack = character.attacks["attack2"]
				return state_attack_startup
	else:
		do_move(get_move_dir())
		if randf() > 0.95 and character.is_on_floor() and not params.is_in_attack_distance():
			state_attack_startup.current_attack = character.attacks["attack_ranged"]
			return state_attack_startup
		else:
			return null


func get_move_dir() -> float:
	if character.position.x < character.opponent.position.x:
		return 1
	else:
		return -1
