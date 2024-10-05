# character_state.gd
class_name CharacterState
extends State


@onready var character: Character = get_parent().get_parent() as Character

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", -9.8)


func process_frame(delta: float) -> State:
	if character.always_face_opponent and character.opponent:
		character.face_opponent()
	return null


func process_physics(delta: float) -> State:
	character.velocity.y += gravity * delta
	character.move_and_slide()
	return null
