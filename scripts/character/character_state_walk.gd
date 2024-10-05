# character_state_walk.gd
class_name CharacterStateWalk
extends CharacterState


@onready var state_idle: CharacterStateIdle = get_parent().get_node("CharacterStateIdle") as CharacterStateIdle
@onready var state_jump: CharacterStateJump = get_parent().get_node("CharacterStateJump") as CharacterStateJump
@onready var state_block: CharacterStateBlock = get_parent().get_node("CharacterStateBlock") as CharacterStateBlock
@onready var state_attack: CharacterStateAttack = get_parent().get_node("CharacterStateAttack") as CharacterStateAttack
@onready var state_stun: CharacterStateStun = get_parent().get_node("CharacterStateStun") as CharacterStateStun


func enter() -> void:
	print(character.input_prefix + "walk")
	character.anim.play("walk")


func process_frame(delta: float) -> State:
	super(delta)
	if character.is_stunned:
		return state_stun
	if Input.is_action_pressed(character.input_prefix + "attack1") or Input.is_action_pressed(character.input_prefix + "attack2"):
		return state_attack
	if Input.is_action_pressed(character.input_prefix + "jump") and character.is_on_floor():
		return state_jump
	if Input.is_action_pressed(character.input_prefix + "block"):
		return state_block
	return null


func process_physics(delta: float) -> State:
	super(delta)
	if Input.is_action_pressed(character.input_prefix + "left") or Input.is_action_pressed(character.input_prefix + "right"):
		do_move(get_move_dir())
	else:
		return state_idle
	return null


func get_move_dir() -> float:
	return Input.get_axis(character.input_prefix + "left", character.input_prefix + "right")


func do_move(move_dir: float) -> void:
	character.velocity.x = move_dir * character.move_speed


func exit() -> void:
	character.velocity.x = 0
