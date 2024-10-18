# character_state_knokdown_down.gd
class_name CharacterStateKnokdownDown
extends CharacterState


var timer: float = 0


func _ready() -> void:
	state_name = "knokdown_down"


func enter() -> void:
	super()
	character.anim.play("knokdown_down")
	timer = character.knokdown_down_duration
	character.velocity.x = 0
	character.velocity.y = 0


func process_physics(delta: float) -> State:
	super(delta)
	
	if character.knokdown_timer <= 0:
		character.knokdown_timer = 0
		return state_idle
	else:
		character.knokdown_timer -= delta
	
	if timer <= 0:
		timer = 0
		return state_knokdown_up
	else:
		timer -= delta
		return null
