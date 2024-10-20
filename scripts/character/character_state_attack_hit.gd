# character_state_attack_hit.gd
class_name CharacterStateAttackHit
extends CharacterStateAttack


func _ready() -> void:
	state_name = "attack_hit"


func enter() -> void:
	super()
	
	if current_attack.ignore_gravity_hit:
		character.ignore_gravity = true
	
	duration = current_attack.duration_hit
	current_attack.enter_hit()


func exit() -> void:
	super()
	current_attack.exit_hit()


func process_physics(delta: float) -> State:
	super(delta)
	current_attack.physics_hit()
	
	var color = Color(1, 0, 0)
	if character.input_prefix == "p1_":
		character.frame_data_bar.update_top_block_color(color)
	else:
		character.frame_data_bar.update_bot_block_color(color)
	
	if duration <= 0:
		state_attack_recovery.current_attack = current_attack
		return state_attack_recovery
	else:
		duration -= delta
		return null
