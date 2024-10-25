# character_state_attack.gd
class_name CharacterStateAttack
extends CharacterState


var current_attack: Attack
var duration: int = 0


func _ready() -> void:
	state_name = "attack"


func enter() -> void:
	super()
	duration = current_attack.duration
	current_attack.enter()


func process_physics(delta: float) -> State:
	super(delta)
	
	current_attack.physics(delta)
	
	if duration <= 0:
		duration = 0
		return state_idle
	else:
		duration -= 1
		return null


func exit() -> void:
	super()
	current_attack.exit()
	character.ignore_gravity = false
