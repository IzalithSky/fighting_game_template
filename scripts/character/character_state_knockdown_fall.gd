# character_state_knockdown_fall.gd
class_name CharacterStateKnockdownFall
extends CharacterState


var timer: float = 0


func _ready() -> void:
	state_name = "knockdown_fall"


func enter() -> void:
	super()
	character.play_anim("knockdown_fall", 0, -40)
	character.is_invincible = true
	character.knockdown_timer = character.knockdown_duration
	timer = character.knockdown_fall_duration


func process_physics(delta: float) -> State:
	super(delta)
	
	if character.is_on_floor():
		character.velocity.x = 0
		character.velocity.y = 0
	
	if character.knockdown_timer <= 0:
		character.knockdown_timer = 0
		return state_idle
	else:
		character.knockdown_timer -= delta
	
	if timer <= 0:
		timer = 0
		return state_knockdown_down
	else:
		timer -= delta
		return null
