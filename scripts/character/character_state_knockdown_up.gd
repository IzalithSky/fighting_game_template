# character_state_knockdown_up.gd
class_name CharacterStateKnockdownUp
extends CharacterState


func _ready() -> void:
	state_name = "knockdown_up"


func enter() -> void:
	super()
	character.anim.play("knockdown_up")
	character.velocity.x = 0
	character.velocity.y = 0


func exit() -> void:
	super()
	character.knockdown_timer = 0
	character.start_active_invicibility()


func process_physics(delta: float) -> State:
	super(delta)
	
	if character.knockdown_timer <= 0:
		character.knockdown_timer = 0
		return state_idle
	else:
		character.knockdown_timer -= delta
		return null
