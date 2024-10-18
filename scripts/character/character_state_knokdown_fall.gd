# character_state_knokdown_fall.gd
class_name CharacterStateKnokdownFall
extends CharacterState


var timer: float = 0


func _ready() -> void:
	state_name = "knokdown_fall"


func enter() -> void:
	super()
	character.anim.play("knokdown_fall")
	character.is_invincible = true
	character.knokdown_timer = character.knokdown_duration
	timer = character.knokdown_fall_duration
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
		return state_knokdown_down
	else:
		timer -= delta
		return null
