# character.gd
class_name Character
extends CharacterBody2D


@export var max_hp: int = 100
@export var move_speed: float = 275
@export var jump_velocity: float = 400.0
@export var input_prefix: String = "p1_"  # To switch between p1_ and p2_
@export var opponent: Character
@export var always_face_opponent: bool = true
@export var frame_data_bar: FrameDataBar

signal damaged(amount: int)
signal died()

var current_hp: int = max_hp
var attacks: Dictionary = {}
var is_opponent_right: bool = true

@onready var fsm: CharacterStateMachine = $CharacterStateMachine
@onready var anim: AnimatedSprite2D = $Animations
@onready var sound_block = $sound/block
@onready var state_label = $StateLabel
@onready var hurtbox: Area2D = $hurtbox


func _ready() -> void:
	load_attack_data()
	fsm.init()


func _physics_process(delta: float) -> void:
	fsm.process_physics(delta)			
	state_label.text = fsm.state()


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
	print("Attacks loaded successfully. Total attacks: ", attacks.size())


func face_opponent() -> void:
	var opponent_pos = opponent.global_position
	if opponent_pos.x > global_position.x:
		is_opponent_right = true
		flip_sprite(1)
	elif opponent_pos.x < global_position.x:
		is_opponent_right = false
		flip_sprite(-1)


func take_damage(amount: int, stun_duration: float = 0.0) -> void:
	var actual_damage = amount
	var actual_stun_duration = stun_duration
	
	if is_blocking():
		sound_block.play()
		actual_damage = max(1, int(amount * 0.2))
		actual_stun_duration = stun_duration * 0.6
	
	current_hp -= actual_damage
	emit_signal("damaged", actual_damage)

	if current_hp <= 0:
		die()
	elif actual_stun_duration > 0.0:
		initiate_stun(actual_stun_duration)


func initiate_stun(stun_duration: float) -> void:
	fsm.apply_stun(stun_duration)


func is_blocking() -> bool:
	return fsm.is_state("block")


func die() -> void:
	emit_signal("died")


func flip_sprite(direction: float) -> void:
	if direction > 0:
		anim.flip_h = false
	elif direction < 0:
		anim.flip_h = true
	for attack in attacks.values():
		attack.scale.x = direction


func reset(new_position: Vector2) -> void:
	current_hp = max_hp
	position = new_position
	velocity = Vector2.ZERO
	fsm.reset()
