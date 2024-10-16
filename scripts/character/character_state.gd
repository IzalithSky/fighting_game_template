# character_state.gd
class_name CharacterState
extends State

@export var character: Character

@onready var fsm: CharacterStateMachine = get_parent() as CharacterStateMachine
@onready var state_idle: CharacterStateIdle = get_parent().get_node("Idle") as CharacterStateIdle
@onready var state_stun: CharacterStateStun = get_parent().get_node("Stun") as CharacterStateStun
@onready var state_knokdown_fall: CharacterStateKnokdownFall = get_parent().get_node("KnokdownFall") as CharacterStateKnokdownFall
@onready var state_knokdown_down: CharacterStateKnokdownDown = get_parent().get_node("KnokdownDown") as CharacterStateKnokdownDown
@onready var state_knokdown_up: CharacterStateKnokdownUp = get_parent().get_node("KnokdownUp") as CharacterStateKnokdownUp
@onready var state_attack_startup: CharacterStateAttackStartup = get_parent().get_node("AttackStartup") as CharacterStateAttackStartup
@onready var state_attack_hit: CharacterStateAttackHit = get_parent().get_node("AttackHit") as CharacterStateAttackHit
@onready var state_attack_recovery: CharacterStateAttackRecovery = get_parent().get_node("AttackRecovery") as CharacterStateAttackRecovery
@onready var state_walk: CharacterStateWalk = get_parent().get_node("Walk") as CharacterStateWalk
@onready var state_jump: CharacterStateJump = get_parent().get_node("Jump") as CharacterStateJump
@onready var state_block: CharacterStateBlock = get_parent().get_node("Block") as CharacterStateBlock


var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", -9.8)


func enter() -> void:
	print(character.input_prefix + state_name)


func process_physics(delta: float) -> State:
	if character.always_face_opponent and character.opponent:
		character.face_opponent()
	character.velocity.y += gravity * delta
	character.move_and_slide()
	return null


func apply_stun(duration: float) -> State:
	state_stun.stun_timer = duration
	state_stun.total_stun_duration += duration
	
	if fsm.is_state("stun"):
		return null
	else:
		return state_stun
