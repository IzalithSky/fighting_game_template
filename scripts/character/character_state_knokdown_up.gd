# character_state_knokdown_up.gd
class_name CharacterStateKnokdownUp
extends CharacterState


func _ready() -> void:
	state_name = "knokdown_up"


func enter() -> void:
	super()
	character.anim.play("knokdown_up")
	character.velocity.x = 0
	character.velocity.y = 0


func exit() -> void:
	super()
	character.knokdown_timer = 0
	character.start_active_invicibility()


func process_physics(delta: float) -> State:
	super(delta)
	
	if character.knokdown_timer <= 0:
		character.knokdown_timer = 0
		return state_idle
	else:
		character.knokdown_timer -= delta
		return null
