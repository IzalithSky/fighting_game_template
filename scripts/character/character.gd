# character.gd
class_name Character
extends CharacterBody2D


@export var max_hp: int = 100
@export var move_speed: float = 275
@export var jump_velocity: float = 400.0
@export var knockdown_fall_duration: float = 0.4
@export var knockdown_down_duration: float = 0.4
@export var knockdown_duration: float = 2
@export var active_invincibility_duration = 0.4
@export var stun_to_knowkdown_duration: float = 1
@export var max_jumps: int = 2
@export var input_prefix: String = "p1_"  # To switch between p1_ and p2_
@export var opponent: Character
@export var always_face_opponent: bool = true
@export var frame_data_bar: FrameDataBar
@export var fsm: CharacterStateMachine

signal damaged(amount: int)
signal died()

var current_hp: int = max_hp
var attacks: Dictionary = {}
var is_opponent_right: bool = true
var is_invincible: bool = false
var knockdown_timer: float = 0
var active_invincibility_timer: float = 0
var jumps_left: int = max_jumps
var ignore_gravity: bool = false

@onready var anim: AnimatedSprite2D = $Animations
@onready var sound_block = $sound/block
@onready var state_label = $StateLabel
@onready var hurtbox: Area2D = $hurtbox
@onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", -9.8)


func _ready() -> void:
	load_attack_data()
	fsm.init()


func _physics_process(delta: float) -> void:
	fsm.process_physics(delta)			
	
	manage_active_invincibility(delta)
	
	if not (fsm.is_state("stun")
		or fsm.is_state("knockdown_fall")
		or fsm.is_state("knockdown_down")
		or fsm.is_state("knockdown_up")
		or fsm.is_state("attack_startup")
		or fsm.is_state("attack_hit")
		or fsm.is_state("attack_recovery")):
		if always_face_opponent and opponent:
			face_opponent()
	if not ignore_gravity:
		velocity.y += gravity * delta
	move_and_slide()
	
	if is_on_floor():
		jumps_left = max_jumps
	state_label.text = fsm.state() + " " + str(jumps_left) if not is_invincible else "[i] " + fsm.state() + " " + str(jumps_left)


func _input(event: InputEvent) -> void:
	fsm.process_input(event)


func load_attack_data() -> void:
	for child in get_children():
		if child is Attack:
			var attack_name = child.name
			if attack_name != "":
				attacks[attack_name] = child
			else:
				printerr("Attack node has no name: ", child.name)


func face_opponent() -> void:
	var opponent_pos = opponent.global_position
	if opponent_pos.x > global_position.x:
		is_opponent_right = true
		flip_sprite(1)
	else:
		is_opponent_right = false
		flip_sprite(-1)


func take_damage(amount: int, stun_duration: float = 0.0) -> void:
	if is_invincible:
		return
	
	var actual_damage = amount
	
	if is_blocking():
		sound_block.play()
		actual_damage = max(1, int(amount * 0.2))
	
	current_hp -= actual_damage
	emit_signal("damaged", actual_damage)

	if current_hp <= 0:
		die()
	elif stun_duration > 0.0:
		initiate_stun(stun_duration)


func initiate_stun(stun_duration: float) -> void:
	fsm.apply_stun(stun_duration)


func is_blocking() -> bool:
	return fsm.is_state("block")


func die() -> void:
	emit_signal("died")


func flip_sprite(direction: float) -> void:	
	anim.scale.x = direction
	
	for attack in attacks.values():
		attack.scale.x = direction


func start_active_invicibility():
	active_invincibility_timer = active_invincibility_duration


func manage_active_invincibility(delta: float):
	if fsm.is_state("knockdown_fall"):
		return
	if fsm.is_state("knockdown_down"):
		return
	if fsm.is_state("knockdown_up"):
		return
		
	if active_invincibility_timer <= 0:
		is_invincible = false
	else:
		active_invincibility_timer -= delta


func play_anim(anim_name: String, offset_x: float, offset_y: float):
	anim.position = Vector2(offset_x, offset_y)
	anim.play(anim_name)


func reset(new_position: Vector2) -> void:
	current_hp = max_hp
	position = new_position
	velocity = Vector2.ZERO
	fsm.reset()
