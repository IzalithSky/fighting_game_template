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
@onready var state_attack: CharacterStateAttack = get_parent().get_node("Attack") as CharacterStateAttack
@onready var state_walk: CharacterStateWalk = get_parent().get_node("Walk") as CharacterStateWalk
@onready var state_jump: CharacterStateJump = get_parent().get_node("Jump") as CharacterStateJump
@onready var state_block: CharacterStateBlock = get_parent().get_node("Block") as CharacterStateBlock


func enter() -> void:
	print(character.input_prefix + state_name)


func apply_stun(frames: int) -> State:
	state_stun.frames = frames
	state_stun.total_stun_duration += frames
	
	if fsm.is_state("stun"):
		return null
	else:
		return state_stun
