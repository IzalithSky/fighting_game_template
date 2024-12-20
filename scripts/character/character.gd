# character.gd
class_name Character
extends CharacterBody2D


@export var max_hp: int = 100
@export var max_mp: float = 100
@export var focus_mp_gain_rate: float = 20
@export var idle_mp_gain_rate: float = 4
@export var move_speed: float = 275
@export var jump_velocity: float = 400.0
@export var knockdown_fall_duration: float = 0.4
@export var knockdown_down_duration: float = 0.4
@export var knockdown_duration: float = 2
@export var active_invincibility_duration = 0.4
@export var stun_to_knowkdown_duration: float = 1
@export var max_jumps: int = 2
@export var intro_anim_duration: float = 0
@export var win_anim_duration: float = 0
@export var character_intro_outro_anim_offset: Vector2 = Vector2(0, -40)
@export var input_prefix: String = "p1_"  # To switch between p1_ and p2_
@export var opponent: Character
@export var always_face_opponent: bool = true
@export var frame_data_bar: FrameDataBar
@export var fsm: CharacterStateMachine

signal damaged(amount: int)
signal kod()
signal mpchanged(current_mp: float)

var current_hp: int = max_hp
var current_mp: float = 0
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
@onready var hurtbox = $hurtbox
@onready var hit_sparks_effect: AnimatedSprite2D = $hurtbox/hit_sparks
@onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", -9.8)


func _ready() -> void:
	load_attack_data()
	hit_sparks_effect.visible = false
	fsm.init()


func _physics_process(delta: float) -> void:
	if not ignore_gravity:
		velocity.y += gravity * delta
	
	fsm.process_physics(delta)
	
	manage_active_invincibility(delta)
	
	if not (fsm.is_state("stun")
		or fsm.is_state("knockdown_fall")
		or fsm.is_state("knockdown_down")
		or fsm.is_state("knockdown_up")
		or fsm.is_state("KO")
		or fsm.is_state("attack")):
		if always_face_opponent and opponent:
			face_opponent()

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


func take_damage(damage: int, stun_duration: float, attack_sound) -> void:
	if is_invincible:
		return
	
	hit_sparks_effect.visible = true
	if is_blocking():
		sound_block.play()
		hit_sparks_effect.play("block")
	elif attack_sound:
		attack_sound.play()
		hit_sparks_effect.play("hit")
	
	current_hp -= damage
	emit_signal("damaged", damage)

	if current_hp <= 0:
		ko()
	elif stun_duration > 0.0:
		initiate_stun(stun_duration)


func spend_mp(amount: float) -> bool:
	if amount <= 0:
		return false
	if current_mp >= amount:
		current_mp -= amount
		emit_signal("mpchanged", current_mp)
		return true
	else:
		return false


func gain_mp(amount: float) -> void:
	if amount <= 0:
		return
	current_mp = min(max_mp, current_mp + amount)
	emit_signal("mpchanged", current_mp)


func initiate_stun(stun_duration: float) -> void:
	fsm.apply_stun(stun_duration)


func is_blocking() -> bool:
	return fsm.is_state("block")


func ko() -> void:
	emit_signal("kod")


func flip_sprite(direction: float) -> void:	
	anim.scale.x = direction
	hurtbox.scale.x = direction
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
	current_mp = 0
	position = new_position
	velocity = Vector2.ZERO
	fsm.reset()


func draw_activity(is_active: bool):
	draw_framedata(Color.INDIAN_RED if is_active else Color.SEA_GREEN)


func draw_recovery():
	draw_framedata(Color.SKY_BLUE)


func draw_framedata(color: Color):
	if input_prefix == "p1_":
		frame_data_bar.update_top_block_color(color)
	else:
		frame_data_bar.update_bot_block_color(color)


func has_mp_for_attack(attack_name: String) -> bool:
	if not attacks.has(attack_name):
		return false
	var a = attacks[attack_name]
	if not a:
		return false
	if a.mp_cost <= current_mp:
		return true
	return false
