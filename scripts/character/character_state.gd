# character_state.gd
class_name CharacterState
extends State


@export var character: Character

@onready var fsm: CharacterStateMachine = get_parent() as CharacterStateMachine
@onready var state_idle: CharacterStateIdle = get_parent().get_node("Idle") as CharacterStateIdle
@onready var state_idle_locked: CharacterStateIdleLocked = get_parent().get_node("IdleLocked") as CharacterStateIdleLocked
@onready var state_focus: CharacterStateFocus = get_parent().get_node("Focus") as CharacterStateFocus
@onready var state_stun: CharacterStateStun = get_parent().get_node("Stun") as CharacterStateStun
@onready var state_knockdown_fall: CharacterStateKnockdownFall = get_parent().get_node("KnockdownFall") as CharacterStateKnockdownFall
@onready var state_knockdown_down: CharacterStateKnockdownDown = get_parent().get_node("KnockdownDown") as CharacterStateKnockdownDown
@onready var state_knockdown_up: CharacterStateKnockdownUp = get_parent().get_node("KnockdownUp") as CharacterStateKnockdownUp
@onready var state_attack: CharacterStateAttack = get_parent().get_node("Attack") as CharacterStateAttack
@onready var state_walk: CharacterStateWalk = get_parent().get_node("Walk") as CharacterStateWalk
@onready var state_jump: CharacterStateJump = get_parent().get_node("Jump") as CharacterStateJump
@onready var state_block: CharacterStateBlock = get_parent().get_node("Block") as CharacterStateBlock
@onready var state_intro: CharacterStateIntro = get_parent().get_node("Intro") as CharacterStateIntro
@onready var state_ko: CharacterStateKO = get_parent().get_node("KO") as CharacterStateKO
@onready var state_win: CharacterStateWin = get_parent().get_node("Win") as CharacterStateWin


func enter() -> void:
	print(character.input_prefix + state_name)


func apply_stun(duration: float) -> State:
	state_stun.stun_timer = duration
	state_stun.total_stun_duration += duration
	
	if fsm.is_state("stun"):
		return null
	else:
		return state_stun


func start_intro() -> State:
	return state_intro


func start_round() -> State:
	return state_idle


func end_round() -> State:
	if character.current_hp > 0 and character.opponent.current_hp > 0:
		if character.current_hp == character.opponent.current_hp:
			return state_win
		if character.current_hp > character.opponent.current_hp:
			return state_win
		else:
			return state_idle_locked
			
	if character.current_hp <= 0:
		return state_ko
	return state_win


func has_mp_for_attack(attack: Attack) -> bool:
	if attack.mp_cost <= character.current_mp:
		character.spend_mp(attack.mp_cost)
		return true
	return false
