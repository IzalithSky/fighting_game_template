# character_state_block.gd
class_name CharacterStateBlock
extends CharacterState


@onready var state_idle: CharacterStateIdle = get_parent().get_node("CharacterStateIdle") as CharacterStateIdle
@onready var state_walk: CharacterStateWalk = get_parent().get_node("CharacterStateWalk") as CharacterStateWalk
@onready var state_jump: CharacterStateJump = get_parent().get_node("CharacterStateJump") as CharacterStateJump
@onready var state_stun: CharacterStateStun = get_parent().get_node("CharacterStateStun") as CharacterStateStun


func enter() -> void:
	print(character.input_prefix + "block")
	character.is_blocking = true
	character.velocity.x = 0
	character.velocity.y = 0
	character.anim.play("block")


func process_frame(delta: float) -> State:
	super(delta)
	if character.is_stunned:
		return state_stun
	return null


func process_input(event: InputEvent) -> State:
	if event.is_action_released(character.input_prefix + "block"):
		character.is_blocking = false
		return state_idle
	return null
