# character_state_attack_recovery.gd
class_name CharacterStateAttackRecovery
extends CharacterStateAttack


func _ready() -> void:
	state_name = "attack_recovery"


func enter() -> void:
	super()
	duration = current_attack.duration_recovery
	current_attack.enter_recovery()


func exit() -> void:
	super()
	current_attack.exit_recovery()


func process_physics(delta: float) -> State:
	super(delta)
	current_attack.physics_recovery()
	
	var color = Color(0, 0, 1)
	if character.input_prefix == "p1_":
		character.frame_data_bar.update_top_block_color(color)
	else:
		character.frame_data_bar.update_bot_block_color(color)
	
	if duration <= 0:
		return state_idle
	else:
		duration -= delta
		return null
