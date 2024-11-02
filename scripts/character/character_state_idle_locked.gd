# character_state_idle_locked.gd
class_name CharacterStateIdleLocked
extends CharacterState


func _ready() -> void:
	state_name = "idle_locked"


func enter() -> void:
	super()
	character.play_anim("idle", 0, -40)


func process_physics(delta: float) -> State:
	super(delta)
	
	if character.is_on_floor():
		character.velocity.x = 0
		character.velocity.y = 0
		
	return null
