# character_state_intro.gd
class_name CharacterStateIntro
extends CharacterState


var intro_anim_timer: float = 0


func _ready() -> void:
	state_name = "intro"


func enter() -> void:
	super()
	intro_anim_timer = character.intro_anim_duration
	character.play_anim("intro", 0, -40)


func process_physics(delta: float) -> State:
	super(delta)

	if intro_anim_timer <= 0:
		intro_anim_timer = 0
		character.play_anim("intro_loop", 0, -40)
	else:
		intro_anim_timer -= delta
	return null
