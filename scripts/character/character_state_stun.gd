# character_state_stun.gd
class_name CharacterStateStun
extends CharacterState


func _ready() -> void:
	state_name = "stun"


func enter() -> void:
	super()
	character.anim.play("stun")
	character.is_attacking = false
	character.is_blocking = false


func process_physics(delta: float) -> State:
	character.stun_timer -= delta
	if character.stun_timer <= 0:
		character.stun_timer = 0
		character.is_stunned = false
		return state_idle
	return null
