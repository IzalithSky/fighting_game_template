# character_state_idle.gd
class_name CharacterStateIdle
extends CharacterState


func _ready() -> void:
	state_name = "idle"


func enter() -> void:
	super()
	character.anim.play("idle")
	character.velocity.x = 0
	character.velocity.y = 0
