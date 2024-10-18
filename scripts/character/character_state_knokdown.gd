# character_state_knokdown.gd
class_name CharacterStateKnokdown
extends CharacterState


var knokdown_timer: float = 0


func _ready() -> void:
	state_name = "knokdown"


func enter() -> void:
	super()
	character.anim.play("knokdown")
	character.is_invincible = true
	knokdown_timer = character.knokdown_duration
	character.velocity.x = 0
	character.velocity.y = 0


func exit() -> void:
	super()
	character.is_invincible = false
	knokdown_timer = 0


func process_physics(delta: float) -> State:
	super(delta)
	
	if knokdown_timer <= 0:
		knokdown_timer = 0
		return state_idle
	else:
		knokdown_timer -= delta
		return null
