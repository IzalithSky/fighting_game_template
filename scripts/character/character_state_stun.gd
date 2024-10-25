# character_state_stun.gd
class_name CharacterStateStun
extends CharacterState


var frames: int = 0
var total_stun_duration: int = 0


func _ready() -> void:
	state_name = "stun"


func enter() -> void:
	super()
	character.play_anim("stun", 0, -40)


func exit() -> void:
	super()
	total_stun_duration = 0


func process_physics(delta: float) -> State:
	super(delta)
	
	var color = Color(1, 1, 0)
	if character.input_prefix == "p1_":
		character.frame_data_bar.update_top_block_color(color)
	else:
		character.frame_data_bar.update_bot_block_color(color)
	
	if total_stun_duration >= character.stun_to_knowkdown_duration:
		return state_knockdown_fall
	
	if frames <= 0:
		frames = 0
		total_stun_duration = 0
		return state_idle
	else:
		frames -= 1
		return null
