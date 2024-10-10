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
@onready var hurtbox = $hurtbox/collider
@onready var slash_attack = $hitboxes
@onready var slash_hitbox1 = $hitboxes/slash_hitbox1  # Adjust this to the correct node path
@onready var slash_hitbox2 = $hitboxes/slash_hitbox2  # Adjust this to the correct node path
@onready var sound_hit1 = $sound/hit1
@onready var sound_hit2 = $sound/hit2
@onready var sound_swing = $sound/swing
@onready var sound_block = $sound/block
@onready var state_label = $StateLabel


func _ready() -> void:
	slash_attack.connect("body_entered", on_hitbox_body_entered)
	
	load_attack_data()
	disable_hitboxes()
	
	fsm.init()


func _physics_process(delta: float) -> void:
	fsm.process_physics(delta)			
	state_label.text = fsm.state()


func _input(event: InputEvent) -> void:
	fsm.process_input(event)


func load_attack_data() -> void:
	var attacks_node = $Attacks
	if not attacks_node:
		printerr("Attacks node not found in the scene")
		return
	
	for child in attacks_node.get_children():
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


func on_hitbox_body_entered(body: Node) -> void:
	if body != self and body.has_method("take_damage"):
		if not body.is_blocking():
			if anim.animation == "attack1":
				sound_hit1.play()
			elif anim.animation == "attack2":
				sound_hit2.play()
		
		var attack: Attack = (fsm.current_state as CharacterStateAttack).current_attack
		body.take_damage(attack.damage, attack.stun_duration)
		apply_pushback(body, attack.pushback)


func apply_pushback(body: Node, pushback_force: Vector2) -> void:	
	var pushback_direction = 1 if is_opponent_right else -1
	if body is CharacterBody2D:
		body.velocity.x = pushback_direction * pushback_force.x
		body.velocity.y = -pushback_force.y


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
	slash_attack.scale.x = direction


func disable_hitboxes() -> void:
	slash_hitbox1.call_deferred("set_disabled", true)
	slash_hitbox2.call_deferred("set_disabled", true)


func reset(new_position: Vector2) -> void:
	current_hp = max_hp
	position = new_position
	velocity = Vector2.ZERO
	disable_hitboxes()
	fsm.reset()
