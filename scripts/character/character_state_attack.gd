# character_state_attack.gd
class_name CharacterStateAttack
extends CharacterState


var current_attack: Attack
var duration: float = 0


func _ready() -> void:
	state_name = "attack"


func enter() -> void:
	super()


func process_physics(delta: float) -> State:
	super(delta)
	if character.is_on_floor():
		character.velocity.x = 0
		character.velocity.y = 0
	return null
