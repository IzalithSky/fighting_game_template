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
			character.anim.play("flip_right")
		else:
			character.velocity.x = -character.move_speed
			character.anim.play("flip_left")
	elif not params.is_opponent_above():
		if character.is_opponent_right:
			character.velocity.x = -character.move_speed
			character.anim.play("flip_right")
		else:
			character.velocity.x = character.move_speed
			character.anim.play("flip_left")
				
	character.velocity.y = -character.jump_velocity


func process_physics(delta: float) -> State:
	super(delta)
	
	if (params.projectile_warning == params.ProjectileWarning.WARNING 
			and not params.is_in_attack_distance() 
			and character.jumps_left > 0
			and params.is_past_jump_cd()):
		return state_jump
	
	if params.is_in_attack_distance():
		if randf() < 0.5 and not character.opponent.is_invincible:
			state_attack_startup.current_attack = character.attacks["attack1"]
		else:
			state_attack_startup.current_attack = character.attacks["attack2"]
		return state_attack_startup
	
	if character.is_on_floor() and character.velocity.y >= 0:
		return state_idle
	
	return null
