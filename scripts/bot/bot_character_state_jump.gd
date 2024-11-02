# bot_character_state_jump.gd
class_name BotCharacterStateJump
extends CharacterStateJump


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func enter() -> void:
	super()
	character.velocity.x = 0
	character.velocity.y = 0
	params.until_can_jump = params.jump_delay
	
	if params.is_in_jump_distance() or character.fsm.is_state("jump"):
		if character.is_opponent_right:
			character.velocity.x = character.move_speed
			character.play_anim("flip_right", 0, -40)
		else:
			character.velocity.x = -character.move_speed
			character.play_anim("flip_left", 0, -40)
	elif not params.is_opponent_above():
		if character.is_opponent_right:
			character.velocity.x = -character.move_speed
			character.play_anim("flip_right", 0, -40)
		else:
			character.velocity.x = character.move_speed
			character.play_anim("flip_left", 0, -40)
				
	character.velocity.y = -character.jump_velocity


func process_physics(delta: float) -> State:
	super(delta)
	
	if params.is_enemy_in_attack_range("attack1"):
		state_attack.current_attack = character.attacks["attack1"]
		return state_attack
	if params.is_enemy_in_attack_range("attack2"):
		state_attack.current_attack = character.attacks["attack2"]
		return state_attack
	
	if (params.projectile_warning == params.ProjectileWarning.WARNING 
			and character.jumps_left > 0
			and params.is_past_jump_cd()):
		return state_jump
	
	if character.is_on_floor() and character.velocity.y >= 0:
		return state_idle
	
	return null
