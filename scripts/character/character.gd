# character.gd
class_name Character
extends CharacterBody2D


@export var max_hp: int = 100
@export var move_speed: float = 275
@export var jump_velocity: float = 400.0
@export var input_prefix: String = "p1_"  # To switch between p1_ and p2_
@export var attack_data_file: String = "res://attack_data.json"  # Path to the JSON file
@export var opponent: Character
@export var always_face_opponent: bool = true

signal damaged(amount: int)
signal died()

var current_hp: int = max_hp
var stun_timer: float = 0.0  # Timer for stun durations
var current_attack_damage: int = 0  # Damage of current attack
var attack_stun_duration: float = 0.0  # Stun duration of current attack
var current_pushback_force: float = 0.0  # Pushback force of current attack
var current_vertical_pushback_force: float = 0.0  # Vertical pushback force of current attack
var current_attack_data: Dictionary = {}  # Dictionary to hold data for the current attack
var attack_data: Dictionary = {}
var is_opponent_right: bool = true
var is_attacking: bool = false
var is_blocking: bool = false
var is_stunned: bool = false

@onready var fsm: StateMachine = $StateMachine
@onready var anim: AnimatedSprite2D = $Animations
@onready var hurtbox = $hurtbox/collider
@onready var slash_attack = $hitboxes
@onready var slash_hitbox1 = $hitboxes/slash_hitbox1  # Adjust this to the correct node path
@onready var slash_hitbox2 = $hitboxes/slash_hitbox2  # Adjust this to the correct node path
@onready var sound_hit1 = $sound/hit1
@onready var sound_hit2 = $sound/hit2
@onready var sound_swing = $sound/swing
@onready var sound_block = $sound/block


func _ready() -> void:
	anim.connect("animation_finished", on_animation_finished)
	anim.connect("frame_changed", on_animation_frame_changed)
	slash_attack.connect("body_entered", on_hitbox_body_entered)
	
	load_attack_data()
	disable_hitboxes()
	
	fsm.init()


func _process(delta: float) -> void:
	fsm.process_frame(delta)


func _physics_process(delta: float) -> void:
	fsm.process_physics(delta)


func _input(event: InputEvent) -> void:
	fsm.process_input(event)


func load_attack_data() -> void:
	# Load the JSON file
	var file = FileAccess.open(attack_data_file, FileAccess.READ)
	if file:
		var json_data = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_data)

		if error == OK:
			attack_data = json.get_data()
			for attack_name in attack_data.keys():
				var active_frames = attack_data[attack_name]["active_frames"]
				if active_frames is Array:
					attack_data[attack_name]["active_frames"] = active_frames.map(func(n):
						return int(n)
					)
				
				# Get the hitbox path string
				var hitbox_path = attack_data[attack_name]["hitbox_path"]
				var hitbox_node = get_node(hitbox_path)
				if hitbox_node:
					attack_data[attack_name]["hitbox"] = hitbox_node
		else:
			print("Error parsing JSON at line", json.get_error_line(), ":", json.get_error_message())
	else:
		print("Failed to load file:", attack_data_file)


func face_opponent() -> void:
	var opponent_pos = opponent.global_position
	if opponent_pos.x > global_position.x:
		is_opponent_right = true
		flip_sprite(1)
	elif opponent_pos.x < global_position.x:
		is_opponent_right = false
		flip_sprite(-1)


func on_animation_finished() -> void:
	match anim.animation:
		"attack1", "attack2":
			is_attacking = false


func on_animation_frame_changed() -> void:
	var current_animation = anim.animation
	var current_frame = anim.frame
	
	if attack_data.has(current_animation):
		var attack_info = attack_data[current_animation]
		var hitbox = attack_info["hitbox"]
		var active_frames = attack_info["active_frames"]

		if current_frame in active_frames:
			hitbox.disabled = false
		else:
			hitbox.disabled = true


func on_hitbox_body_entered(body: Node) -> void:
	if body != self and body.has_method("take_damage"):
		if not is_blocking:
			if anim.animation == "attack1":
				sound_hit1.play()
			elif anim.animation == "attack2":
				sound_hit2.play()
		
		body.take_damage(current_attack_damage, attack_stun_duration)
		apply_pushback(body)


func apply_pushback(body: Node) -> void:	
	var pushback_direction = 1 if is_opponent_right else -1
	if body is CharacterBody2D:
		body.velocity.x = pushback_direction * current_pushback_force
		body.velocity.y = -current_vertical_pushback_force


func take_damage(amount: int, stun_duration: float = 0.0) -> void:
	var actual_damage = amount
	var actual_stun_duration = stun_duration
	
	if is_blocking:
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
	is_stunned = true
	stun_timer = stun_duration


func die() -> void:
	emit_signal("died")


func flip_sprite(direction: float) -> void:
	if direction > 0:
		anim.flip_h = false
	elif direction < 0:
		anim.flip_h = true
	slash_attack.scale.x = direction


func initiate_attack(attack_name: String) -> void:
	current_attack_data = attack_data[attack_name]
	current_attack_damage = current_attack_data["damage"]
	attack_stun_duration = current_attack_data["stun_duration"]
	current_pushback_force = current_attack_data.get("pushback_force", 0)  # Default to 0 if not defined
	current_vertical_pushback_force = current_attack_data.get("vertical_pushback_force", 0)  # Default to 0 if not defined


func disable_hitboxes() -> void:
	slash_hitbox1.call_deferred("set_disabled", true)
	slash_hitbox2.call_deferred("set_disabled", true)


func reset(new_position: Vector2) -> void:
	current_hp = max_hp
	position = new_position
	velocity = Vector2.ZERO
	stun_timer = 0.0
	is_attacking = false
	disable_hitboxes()
