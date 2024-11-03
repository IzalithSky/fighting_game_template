# bot_character_state_focus.gd
class_name BotCharacterStateFocus
extends CharacterStateFocus


@onready var params: BotParameters = get_parent().get_node("BotParameters") as BotParameters


func process_physics(delta: float) -> State:
	super(delta)
	
	var opponent_can_reach = params.opponent_can_reach()
	
	if params.projectile_warning == params.ProjectileWarning.WARNING and not opponent_can_reach:
		if character.jumps_left > 0:
			return state_jump
		else:
			return state_block

	if params.projectile_warning == params.ProjectileWarning.IMMINENT:
		return state_block

	if opponent_can_reach and not character.opponent.fsm.is_recovery():
		return state_block

	if params.rng() < 0.8 and not character.opponent.is_invincible:
		if has_mp_for_attack("attack_special1") and params.is_enemy_in_attack_range("attack_special1"):
			state_attack.current_attack = character.attacks["attack_special1"]
			return state_attack
		if has_mp_for_attack("attack_special2") and params.is_enemy_in_attack_range("attack_special2"):
			state_attack.current_attack = character.attacks["attack_special2"]
			return state_attack
		if has_mp_for_attack("attack_special3") and params.is_enemy_in_attack_range("attack_special3"):
			state_attack.current_attack = character.attacks["attack_special3"]
			return state_attack
		if has_mp_for_attack("attack_special4") and params.is_enemy_in_attack_range("attack_special4"):
			state_attack.current_attack = character.attacks["attack_special4"]
			return state_attack
		if params.is_enemy_in_attack_range("attack1"):
			state_attack.current_attack = character.attacks["attack1"]
			return state_attack
		if params.is_enemy_in_attack_range("attack2"):
			state_attack.current_attack = character.attacks["attack2"]
			return state_attack
		
	if character.current_mp >= 60 + randf() * 40:
		return state_idle
		
	return null
