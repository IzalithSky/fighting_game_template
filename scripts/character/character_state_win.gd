# character_state_win.gd
class_name CharacterStateWin
extends CharacterState


var win_anim_timer: float = 0


func _ready() -> void:
	state_name = "win"


func enter() -> void:
	super()
	win_anim_timer = character.win_anim_duration
	character.play_anim("win", character.character_intro_outro_anim_offset.x, character.character_intro_outro_anim_offset.y)


func process_physics(delta: float) -> State:
	super(delta)

	if character.is_on_floor():
		character.velocity.x = 0
		character.velocity.y = 0

	if win_anim_timer <= 0:
		win_anim_timer = 0
		character.play_anim("win_loop", character.character_intro_outro_anim_offset.x, character.character_intro_outro_anim_offset.y)
	else:
		win_anim_timer -= delta
	return null
