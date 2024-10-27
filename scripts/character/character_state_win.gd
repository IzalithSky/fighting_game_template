# character_state_win.gd
class_name CharacterStateWin
extends CharacterState


var win_anim_timer: float = 0


func _ready() -> void:
	state_name = "win"


func enter() -> void:
	super()
	win_anim_timer = character.win_anim_duration
	character.play_anim("win", 0, -40)


func process_physics(delta: float) -> State:
	super(delta)

	if win_anim_timer <= 0:
		win_anim_timer = 0
		character.play_anim("win_loop", 0, -40)
	else:
		win_anim_timer -= delta
	return null
