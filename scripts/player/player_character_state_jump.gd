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
			character.play_anim("flip_left", 0, -40)
		else:
			character.play_anim("flip_right", 0, -40)
	elif Input.is_action_pressed(character.input_prefix + "right"):
		character.velocity.x = character.move_speed
		if character.is_opponent_right:
			character.play_anim("flip_right", 0, -40)
		else:
			character.play_anim("flip_left", 0, -40)
	else:
		character.play_anim("jump", 0, -40)
	character.velocity.y = -character.jump_velocity


func process_physics(delta: float) -> State:
	super(delta)
	if character.is_on_floor() and character.velocity.y >= 0:
		return state_idle
	else:
		return null


func process_input(event: InputEvent) -> State:
	super(event)
	if event.is_action_pressed(character.input_prefix + "attack1"):
		state_attack.current_attack = character.attacks["attack1"]
		return state_attack
	elif event.is_action_pressed(character.input_prefix + "attack2"):
		state_attack.current_attack = character.attacks["attack2"]
		return state_attack
	elif Input.is_action_just_pressed(character.input_prefix + "jump") and character.jumps_left > 0:
		return state_jump
	return null
