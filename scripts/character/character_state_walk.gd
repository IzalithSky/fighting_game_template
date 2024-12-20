# character_state_walk.gd
class_name CharacterStateWalk
extends CharacterState


func _ready() -> void:
	state_name = "walk"


func enter() -> void:
	super()
	character.play_anim("walk", 0, -40)


func process_physics(delta: float) -> State:
	super(delta)
	character.gain_mp(character.idle_mp_gain_rate * delta)
	return state_idle


func do_move(move_dir: float) -> void:
	if character.is_on_floor():
		character.velocity.x = move_dir * character.move_speed


func exit() -> void:
	character.velocity.x = 0
