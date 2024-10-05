# character_state_idle.gd
class_name CharacterStateIdle
extends CharacterState


@onready var state_walk: CharacterStateWalk = get_parent().get_node("CharacterStateWalk") as CharacterStateWalk
@onready var state_jump: CharacterStateJump = get_parent().get_node("CharacterStateJump") as CharacterStateJump
@onready var state_block: CharacterStateBlock = get_parent().get_node("CharacterStateBlock") as CharacterStateBlock
@onready var state_attack: CharacterStateAttack = get_parent().get_node("CharacterStateAttack") as CharacterStateAttack
@onready var state_stun: CharacterStateStun = get_parent().get_node("CharacterStateStun") as CharacterStateStun


func enter() -> void:
	print(character.input_prefix + "idle")
	character.anim.play("idle")
	character.velocity.x = 0
	character.velocity.y = 0


func process_frame(delta: float) -> State:
	super(delta)
	if character.is_stunned:
		return state_stun
	if Input.is_action_pressed(character.input_prefix + "attack1") or Input.is_action_pressed(character.input_prefix + "attack2"):
		return state_attack
	if Input.is_action_pressed(character.input_prefix + "jump") and character.is_on_floor():
		return state_jump
	if Input.is_action_pressed(character.input_prefix + "left") or Input.is_action_pressed(character.input_prefix + "right"):
		return state_walk
	if Input.is_action_pressed(character.input_prefix + "block"):
		return state_block
	return null	
