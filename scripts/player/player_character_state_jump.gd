# player_character_state_jump.gd
class_name PlayerCharacterStateJump
extends CharacterStateJump


func enter() -> void:
	super()
	character.velocity.x = 0
	character.velocity.y = 0
	if Input.is_action_pressed(character.input_prefix + "left"):
		character.velocity.x = -character.move_speed
		if character.is_opponent_right:
			character.anim.play("flip_left")
		else:
			character.anim.play("flip_right")
	elif Input.is_action_pressed(character.input_prefix + "right"):
		character.velocity.x = character.move_speed
		if character.is_opponent_right:
			character.anim.play("flip_right")
		else:
			character.anim.play("flip_left")
	else:
		character.anim.play("jump")
	character.velocity.y = -character.jump_velocity


func process_frame(delta: float) -> State:
	super(delta)
	if character.is_stunned:
		return state_stun
	if Input.is_action_pressed(character.input_prefix + "attack1") or Input.is_action_pressed(character.input_prefix + "attack2"):
		return state_attack
	return null


func process_physics(delta: float) -> State:
	super(delta)
	if Input.is_action_pressed(character.input_prefix + "attack1") or Input.is_action_pressed(character.input_prefix + "attack2"):
		return state_attack
	if character.is_on_floor() and character.velocity.y >= 0:
		return state_idle
	return null
