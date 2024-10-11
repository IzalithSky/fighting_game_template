# character_state_attack_hit.gd
class_name CharacterStateAttackHit
extends CharacterStateAttack


func _ready() -> void:
	state_name = "attack_hit"


func enter() -> void:
	super()
	duration = current_attack.duration_hit
	current_attack.hitbox.disabled = false
	current_attack.do_hit()


func process_physics(delta: float) -> State:
	super(delta)
	
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


func exit() -> void:
	super()
	current_attack.hitbox.call_deferred("set_disabled", true)
