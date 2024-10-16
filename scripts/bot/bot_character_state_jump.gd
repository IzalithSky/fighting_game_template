# bot_character_state_jump.gd
class_name BotCharacterStateJump
extends CharacterStateJump


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func enter() -> void:
	super()
	character.velocity.x = 0
	character.velocity.y = 0
	if not params.is_in_jump_distance():
		if character.position.x > character.opponent.position.x:
			character.velocity.x = character.move_speed
			if character.is_opponent_right:
				character.anim.play("flip_left")
			else:
				character.anim.play("flip_right")
		else:
			character.velocity.x = -character.move_speed
			if character.is_opponent_right:
				character.anim.play("flip_right")
			else:
				character.anim.play("flip_left")
	else:
		if character.position.x > character.opponent.position.x:
			character.velocity.x = -character.move_speed
			if character.is_opponent_right:
				character.anim.play("flip_left")
			else:
				character.anim.play("flip_right")
		else:
			character.velocity.x = character.move_speed
			if character.is_opponent_right:
				character.anim.play("flip_right")
			else:
				character.anim.play("flip_left")
	character.velocity.y = -character.jump_velocity


func process_physics(delta: float) -> State:
	super(delta)
	if params.is_in_attack_distance():
		if randf() < 0.5 and not character.opponent.is_invincible:
			state_attack_startup.current_attack = character.attacks["attack1"]
		else:
			state_attack_startup.current_attack = character.attacks["attack2"]
		return state_attack_startup
	
	if character.is_on_floor() and character.velocity.y >= 0:
		return state_idle
	
	return null
