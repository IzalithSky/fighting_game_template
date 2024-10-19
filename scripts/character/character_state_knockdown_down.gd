# character_state_knockdown_down.gd
class_name CharacterStateKnockdownDown
extends CharacterState


var timer: float = 0


func _ready() -> void:
	state_name = "knockdown_down"


func enter() -> void:
	super()
	character.anim.play("knockdown_down")
	timer = character.knockdown_down_duration
	character.velocity.x = 0
	character.velocity.y = 0


func process_physics(delta: float) -> State:
	super(delta)
	
	if character.knockdown_timer <= 0:
		character.knockdown_timer = 0
		return state_idle
	else:
		character.knockdown_timer -= delta
	
	if timer <= 0:
		timer = 0
		return state_knockdown_up
	else:
		timer -= delta
		return null
