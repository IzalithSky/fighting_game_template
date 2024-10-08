# bot_character_state_jump.gd
class_name BotCharacterStateJump
extends CharacterStateJump


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func enter() -> void:
	super()
	character.velocity.x = 0
	character.velocity.y = 0
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


func process_frame(delta: float) -> State:
	super(delta)
	if character.is_stunned:
		return state_stun
	if params.is_in_attack_distance():
		if character.opponent.fsm.current_state.state_name == "attack":
			return state_block
		else:
			return state_attack
	return null


func process_physics(delta: float) -> State:
	super(delta)
	if character.is_on_floor() and character.velocity.y >= 0:
		return state_idle
	return null
