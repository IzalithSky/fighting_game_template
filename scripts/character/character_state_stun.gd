# character_state_stun.gd
class_name CharacterStateStun
extends CharacterState


@onready var state_idle: CharacterStateIdle = get_parent().get_node("CharacterStateIdle") as CharacterStateIdle


func enter() -> void:
	print(character.input_prefix + "stun")
	character.anim.play("stun")


func process_frame(delta: float) -> State:
	character.stun_timer -= delta
	if character.stun_timer <= 0:
		character.stun_timer = 0
		character.is_stunned = false
		return state_idle
	return null
