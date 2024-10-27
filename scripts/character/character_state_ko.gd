# character_state_ko.gd
class_name CharacterStateKO
extends CharacterState


func _ready() -> void:
	state_name = "KO"


func enter() -> void:
	super()
	if character.anim.animation != "knockdown_down":
		character.play_anim("knockdown_down", 0, -40)
