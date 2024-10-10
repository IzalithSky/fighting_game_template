# character_state_attack_startup.gd
class_name CharacterStateAttackStartup
extends CharacterStateAttack


func _ready() -> void:
	state_name = "attack_startup"


func enter() -> void:
	super()
	duration = current_attack.duration_startup
	current_attack.hitbox.disabled = true
	character.anim.play(current_attack.animation_name)
	character.sound_swing.play()


func process_physics(delta: float) -> State:
	super(delta)
	
	var color = Color(0, 1, 0)
	if character.input_prefix == "p1_":
		character.frame_data_bar.update_top_block_color(color)
	else:
		character.frame_data_bar.update_bot_block_color(color)
	
	if duration <= 0:
		state_attack_hit.current_attack = current_attack
		return state_attack_hit
	else:
		duration -= delta
		return null
