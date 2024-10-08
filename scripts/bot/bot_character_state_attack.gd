# bot_character_state_attack.gd
class_name BotCharacterStateAttack
extends CharacterStateAttack


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func enter() -> void:
	super()
	if randf() < 0.5:
		character.anim.play("attack1")
		character.sound_swing.play()
		character.initiate_attack("attack1")
	else:
		character.anim.play("attack2")
		character.sound_swing.play()
		character.initiate_attack("attack2")
