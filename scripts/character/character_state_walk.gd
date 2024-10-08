# character_state_walk.gd
class_name CharacterStateWalk
extends CharacterState


func _ready() -> void:
	state_name = "walk"


func enter() -> void:
	super()
	character.anim.play("walk")


func process_frame(delta: float) -> State:
	super(delta)
	if character.is_stunned:
		return state_stun
	return null


func process_physics(delta: float) -> State:
	super(delta)
	return state_idle


func do_move(move_dir: float) -> void:
	character.velocity.x = move_dir * character.move_speed


func exit() -> void:
	character.velocity.x = 0
