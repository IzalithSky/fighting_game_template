# character_state_attack.gd
class_name CharacterStateAttack
extends CharacterState


var current_attack: Attack
var duration: float = 0


func _ready() -> void:
	state_name = "attack"


func enter() -> void:
	super()
	current_attack.enter()


func process_physics(delta: float) -> State:
	super(delta)
	current_attack.physics(delta)
	return null


func exit() -> void:
	super()
	current_attack.exit()
	character.ignore_gravity = false
