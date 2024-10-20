# character_state.gd
class_name CharacterState
extends State

@export var character: Character

@onready var fsm: CharacterStateMachine = get_parent() as CharacterStateMachine
@onready var state_idle: CharacterStateIdle = get_parent().get_node("Idle") as CharacterStateIdle
@onready var state_stun: CharacterStateStun = get_parent().get_node("Stun") as CharacterStateStun
@onready var state_knockdown_fall: CharacterStateKnockdownFall = get_parent().get_node("KnockdownFall") as CharacterStateKnockdownFall
@onready var state_knockdown_down: CharacterStateKnockdownDown = get_parent().get_node("KnockdownDown") as CharacterStateKnockdownDown
@onready var state_knockdown_up: CharacterStateKnockdownUp = get_parent().get_node("KnockdownUp") as CharacterStateKnockdownUp
@onready var state_attack_startup: CharacterStateAttackStartup = get_parent().get_node("AttackStartup") as CharacterStateAttackStartup
@onready var state_attack_hit: CharacterStateAttackHit = get_parent().get_node("AttackHit") as CharacterStateAttackHit
@onready var state_attack_recovery: CharacterStateAttackRecovery = get_parent().get_node("AttackRecovery") as CharacterStateAttackRecovery
@onready var state_walk: CharacterStateWalk = get_parent().get_node("Walk") as CharacterStateWalk
@onready var state_jump: CharacterStateJump = get_parent().get_node("Jump") as CharacterStateJump
@onready var state_block: CharacterStateBlock = get_parent().get_node("Block") as CharacterStateBlock


func enter() -> void:
	print(character.input_prefix + state_name)


func apply_stun(duration: float) -> State:
	state_stun.stun_timer = duration
	state_stun.total_stun_duration += duration
	
	if fsm.is_state("stun"):
		return null
	else:
		return state_stun
