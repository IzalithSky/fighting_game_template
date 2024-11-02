# character_state_jump.gd
class_name CharacterStateJump
extends CharacterState


func _ready() -> void:
	state_name = "jump"


func enter() -> void:
	super()
	character.jumps_left -= 1


func process_physics(delta: float) -> State:
	super(delta)
	character.gain_mp(character.idle_mp_gain_rate * delta)
	return null
