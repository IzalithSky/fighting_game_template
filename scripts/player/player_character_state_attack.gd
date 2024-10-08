# player_character_state_attack.gd
class_name PlayerCharacterStateAttack
extends CharacterStateAttack


func enter() -> void:
	super()
	if Input.is_action_pressed(character.input_prefix + "attack1"):
		character.anim.play("attack1")
		character.sound_swing.play()
		character.initiate_attack("attack1")
	elif Input.is_action_pressed(character.input_prefix + "attack2"):
		character.anim.play("attack2")
		character.sound_swing.play()
		character.initiate_attack("attack2")
