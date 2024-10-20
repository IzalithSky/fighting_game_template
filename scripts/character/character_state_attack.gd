# character_state_attack.gd
class_name CharacterStateAttack
extends CharacterState


var current_attack: Attack
var duration: float = 0


func _ready() -> void:
	state_name = "attack"


func enter() -> void:
	super()
	if current_attack.ignore_gravity:
		character.ignore_gravity = true
	if current_attack.lock_rotation:
		character.lock_rotation = true


func exit() -> void:
	super()
	character.ignore_gravity = false
	character.lock_rotation = false
