# character_state_attack.gd
class_name CharacterStateAttack
extends CharacterState


@onready var state_idle: CharacterStateIdle = get_parent().get_node("CharacterStateIdle") as CharacterStateIdle
@onready var state_stun: CharacterStateStun = get_parent().get_node("CharacterStateStun") as CharacterStateStun


func enter() -> void:
	print(character.input_prefix + "attack")
	character.velocity.x = 0
	character.velocity.y = 0
	character.is_attacking = true
	if Input.is_action_pressed(character.input_prefix + "attack1"):
		character.anim.play("attack1")
		character.sound_swing.play()
		character.initiate_attack("attack1")
	elif Input.is_action_pressed(character.input_prefix + "attack2"):
		character.anim.play("attack2")
		character.sound_swing.play()
		character.initiate_attack("attack2")


func process_frame(delta: float) -> State:
	super(delta)
	if character.is_stunned:
		return state_stun
	if not character.is_attacking:
		character.disable_hitboxes()
		return state_idle
	return null
