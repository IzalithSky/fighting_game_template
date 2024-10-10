# character_state_stun.gd
class_name CharacterStateStun
extends CharacterState


func _ready() -> void:
	state_name = "stun"


func enter() -> void:
	super()
	character.anim.play("stun")
	character.is_attacking = false


func process_physics(delta: float) -> State:
	character.stun_timer -= delta
	if character.stun_timer <= 0:
		character.stun_timer = 0
		return state_idle
	return null
