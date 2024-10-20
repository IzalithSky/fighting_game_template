# character_state_attack_startup.gd
class_name CharacterStateAttackStartup
extends CharacterStateAttack


func _ready() -> void:
	state_name = "attack_startup"


func enter() -> void:
	super()
	
	if current_attack.ignore_gravity_startup:
		character.ignore_gravity = true
	
	duration = current_attack.duration_startup
	current_attack.enter_startup()


func exit() -> void:
	super()
	current_attack.exit_startup()


func process_physics(delta: float) -> State:
	super(delta)
	current_attack.physics_startup()
	
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
