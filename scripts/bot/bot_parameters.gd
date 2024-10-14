# bot_parameters.gd
class_name BotParameters
extends Node


@export var character: Character

@export var idle_only: bool = false
@export var always_block: bool = false
@export var jump_distance: float = 256
@export var attack_distance: float = 55

var opponent_distance: float = 1000

@onready var fsm: CharacterStateMachine = get_parent() as CharacterStateMachine
@onready var state_idle: CharacterStateIdle = get_parent().get_node("Idle") as CharacterStateIdle
@onready var state_stun: CharacterStateStun = get_parent().get_node("Stun") as CharacterStateStun
@onready var state_attack_startup: CharacterStateAttackStartup = get_parent().get_node("AttackStartup") as CharacterStateAttackStartup
@onready var state_attack_hit: CharacterStateAttackHit = get_parent().get_node("AttackHit") as CharacterStateAttackHit
@onready var state_attack_recovery: CharacterStateAttackRecovery = get_parent().get_node("AttackRecovery") as CharacterStateAttackRecovery
@onready var state_walk: CharacterStateWalk = get_parent().get_node("Walk") as CharacterStateWalk
@onready var state_jump: CharacterStateJump = get_parent().get_node("Jump") as CharacterStateJump
@onready var state_block: CharacterStateBlock = get_parent().get_node("Block") as CharacterStateBlock


func _physics_process(delta: float) -> void:
	opponent_distance = abs(character.position.x - character.opponent.position.x)


func is_in_jump_distance() -> bool:
	return opponent_distance >= jump_distance
	
	
func is_in_attack_distance() -> bool:
	return opponent_distance <= attack_distance
