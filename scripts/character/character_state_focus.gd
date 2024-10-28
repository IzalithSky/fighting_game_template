# character_state_focus.gd
class_name CharacterStateFocus
extends CharacterState


func _ready() -> void:
	state_name = "focus"


func process_physics(delta: float) -> State:
	super(delta)
	if character.is_on_floor():
		character.velocity.x = 0
		character.velocity.y = 0
	character.gain_mp(character.focus_mp_gain_rate * delta)
	return null


func enter() -> void:
	super()
	character.velocity.x = 0
	character.velocity.y = 0
	character.play_anim("focus", 0, -40)
