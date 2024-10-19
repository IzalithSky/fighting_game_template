# bot_parameters.gd
class_name BotParameters
extends Node


var character: Character
var jump_distance: float = 256
var attack_distance: float = 50
var projectile_distance: float = 128
var projectile_warning_distance: float = 128
var projectile_imminent_distance: float = 32
var opponent_height_threshold: float = 128
var block_duration: float = 0.5
var rng_persist_duration: float = 0.5
var jump_delay: float = 0.5

var current_block_time: float = 0.0
var current_rng_time: float = 0.0
var until_can_jump: float = 0.0

@onready var fsm: CharacterStateMachine = get_parent() as CharacterStateMachine
@onready var state_idle: CharacterStateIdle = get_parent().get_node("Idle") as CharacterStateIdle
@onready var state_stun: CharacterStateStun = get_parent().get_node("Stun") as CharacterStateStun
@onready var state_attack_startup: CharacterStateAttackStartup = get_parent().get_node("AttackStartup") as CharacterStateAttackStartup
@onready var state_attack_hit: CharacterStateAttackHit = get_parent().get_node("AttackHit") as CharacterStateAttackHit
@onready var state_attack_recovery: CharacterStateAttackRecovery = get_parent().get_node("AttackRecovery") as CharacterStateAttackRecovery
@onready var state_walk: CharacterStateWalk = get_parent().get_node("Walk") as CharacterStateWalk
@onready var state_jump: CharacterStateJump = get_parent().get_node("Jump") as CharacterStateJump
@onready var state_block: CharacterStateBlock = get_parent().get_node("Block") as CharacterStateBlock

enum ProjectileWarning {
	NONE,
	WARNING,
	IMMINENT
}
var projectile_warning: ProjectileWarning = ProjectileWarning.NONE
var current_rng: float = 0


func _physics_process(delta: float) -> void:
	projectile_warning = get_projectile_warning()
	next_rng(delta)
	next_jump(delta)


func is_in_jump_distance() -> bool:
	return abs(character.global_position.x - character.opponent.global_position.x) >= jump_distance


func is_in_attack_distance() -> bool:
	return abs(character.global_position.x - character.opponent.global_position.x) <= attack_distance


func is_in_ranged_distance() -> bool:
	return abs(character.global_position.x - character.opponent.global_position.x) >= projectile_distance


func is_opponent_above() -> bool:
	return character.global_position.y - character.opponent.global_position.y >= opponent_height_threshold


func get_projectile_warning() -> ProjectileWarning:
	for node in get_tree().get_nodes_in_group("projectiles"):
		if node is Projectile and node.character == character.opponent:
			if is_projectile_traveling_towards_me(node):
				var distance_to_projectile = node.global_position.distance_to(character.global_position)
				if distance_to_projectile <= projectile_imminent_distance:
					return ProjectileWarning.IMMINENT
				elif distance_to_projectile <= projectile_warning_distance:
					return ProjectileWarning.WARNING
	return ProjectileWarning.NONE


func is_projectile_traveling_towards_me(projectile: Projectile) -> bool:
	var projectile_direction = sign(projectile.scale.x)
	var relative_position = projectile.global_position.x - character.global_position.x
	if (relative_position > 0 and projectile_direction < 0) or (relative_position < 0 and projectile_direction > 0):
		return true
	return false


func next_rng(delta: float):
	if current_rng_time < 0:
		current_rng = randf()
		current_rng_time = rng_persist_duration
	else:
		current_rng_time -= delta


func rng() -> float:
	return current_rng
	
	
func next_jump(delta: float):
	if until_can_jump > 0:
		until_can_jump -= delta
		
		
func is_past_jump_cd() -> bool:
	return until_can_jump <= 0
