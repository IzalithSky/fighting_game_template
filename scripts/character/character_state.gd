# character_state.gd
class_name CharacterState
extends State


@onready var character: Character = get_parent().get_parent() as Character

@onready var state_idle: CharacterStateIdle = get_parent().get_node("Idle") as CharacterStateIdle
@onready var state_stun: CharacterStateStun = get_parent().get_node("Stun") as CharacterStateStun
@onready var state_attack: CharacterStateAttack = get_parent().get_node("Attack") as CharacterStateAttack
@onready var state_walk: CharacterStateWalk = get_parent().get_node("Walk") as CharacterStateWalk
@onready var state_jump: CharacterStateJump = get_parent().get_node("Jump") as CharacterStateJump
@onready var state_block: CharacterStateBlock = get_parent().get_node("Block") as CharacterStateBlock


var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", -9.8)


func enter() -> void:
	print(character.input_prefix + state_name)


func process_frame(delta: float) -> State:
	if character.always_face_opponent and character.opponent:
		character.face_opponent()
	return null


func process_physics(delta: float) -> State:
	character.velocity.y += gravity * delta
	character.move_and_slide()
	return null
