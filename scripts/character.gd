extends CharacterBody2D

# --- Exported Variables ---
@export var speed: float = 250.0
@export var jump_velocity: float = 400.0
@export var max_hp: int = 100

@export var attack1_dmg: int = 10
@export var attack1_stun_duration: float = 0.5  # Stun duration for attack 1 in seconds
@export var attack2_dmg: int = 20
@export var attack2_stun_duration: float = 1.0  # Stun duration for attack 2 in seconds

@export var input_prefix: String = "p1_"  # To switch between p1_ and p2_
@export var gravity: float = 1200.0  # Gravity strength

# --- Signals ---
signal damaged(amount: int)
signal died()

# --- Enumerations ---
enum State {
	IDLE,
	WALKING,
	JUMPING,
	ATTACKING,
	STUNNED
}

# --- Internal Variables ---
var current_hp: int = max_hp
var current_state: State = State.IDLE
var facing_right: bool = true  # Direction the character is facing
var stun_timer: float = 0.0  # Timer for stun duration
var attack_stun_duration: float = 0.0  # Duration of stun after attack
var current_attack_damage: int = 0  # Damage of current attack
var hitbox_activation_frames: Dictionary = {}

# --- Node References ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox = $hurtbox/collider
@onready var slash_attack = $hitboxes
@onready var slash_hitbox = $hitboxes/slash_hitbox  # Hitbox for attack 1
@onready var slash_hitbox2 = $hitboxes/slash_hitbox2  # Hitbox for attack 2

# --- Lifecycle Methods ---
func _ready() -> void:
	# Initialize hitboxes and activation frames
	disable_hitboxes()
	initialize_hitbox_frames()

	# Connect signals
	anim.connect("animation_finished", on_animation_finished)
	anim.connect("frame_changed", on_animation_frame_changed)
	slash_attack.connect("body_entered", on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_state(delta)
	move_and_slide()

# --- Initialization ---
func initialize_hitbox_frames() -> void:
	hitbox_activation_frames = {
		"attack": {
			"hitbox": slash_hitbox,
			"active_frames": [2, 3]  # Adjust these frames to match your actual animation
		},
		"attack2": {
			"hitbox": slash_hitbox2,
			"active_frames": [3, 4]  # Adjust these frames to match your actual animation
		}
	}

# --- State Handling ---
func handle_state(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle_state(delta)
		State.WALKING:
			handle_walking_state(delta)
		State.JUMPING:
			handle_jumping_state(delta)
		State.ATTACKING:
			handle_attacking_state(delta)
		State.STUNNED:
			handle_stunned_state(delta)

func handle_idle_state(delta: float) -> void:
	var direction = Input.get_axis(input_prefix + "left", input_prefix + "right")
	if Input.is_action_just_pressed(input_prefix + "jump"):
		var jump_direction = 0
		if Input.is_action_pressed(input_prefix + "left") and not Input.is_action_pressed(input_prefix + "right"):
			jump_direction = -1
		elif Input.is_action_pressed(input_prefix + "right") and not Input.is_action_pressed(input_prefix + "left"):
			jump_direction = 1
		initiate_jump(jump_direction)
	elif direction != 0:
		transition_to_state(State.WALKING, direction)
	elif Input.is_action_just_pressed(input_prefix + "attack"):
		initiate_attack(1)
	elif Input.is_action_just_pressed(input_prefix + "attack2"):
		initiate_attack(2)
	else:
		velocity.x = 0
		anim.play("idle")

func handle_walking_state(delta: float) -> void:
	var direction = Input.get_axis(input_prefix + "left", input_prefix + "right")
	if Input.is_action_just_pressed(input_prefix + "jump"):
		var jump_direction = 0
		if Input.is_action_pressed(input_prefix + "left") and not Input.is_action_pressed(input_prefix + "right"):
			jump_direction = -1
		elif Input.is_action_pressed(input_prefix + "right") and not Input.is_action_pressed(input_prefix + "left"):
			jump_direction = 1
		initiate_jump(jump_direction)
	elif direction != 0:
		velocity.x = direction * speed
		anim.play("walk")
		flip_sprite(direction)
	elif Input.is_action_just_pressed(input_prefix + "attack"):
		initiate_attack(1)
	elif Input.is_action_just_pressed(input_prefix + "attack2"):
		initiate_attack(2)
	else:
		transition_to_state(State.IDLE)

func handle_jumping_state(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0
		transition_to_state(State.IDLE)
	
	# Remove air control by not processing horizontal input
	if Input.is_action_just_pressed(input_prefix + "attack"):
		initiate_attack(1)
	elif Input.is_action_just_pressed(input_prefix + "attack2"):
		initiate_attack(2)

func handle_attacking_state(delta: float) -> void:
	if is_on_floor():
		velocity.x = 0  # Lock movement on the ground

func handle_stunned_state(delta: float) -> void:
	stun_timer -= delta
	if stun_timer <= 0.0:
		transition_to_state(State.IDLE)

# --- State Transitions ---
func transition_to_state(new_state: State, direction: float = 0) -> void:
	current_state = new_state
	match new_state:
		State.IDLE:
			anim.play("idle")
		State.WALKING:
			velocity.x = direction * speed
			anim.play("walk")
			flip_sprite(direction)
		State.JUMPING:
			anim.play("jump")
		State.STUNNED:
			anim.play("stunned")

func initiate_jump(direction: int) -> void:
	# Set vertical velocity for the jump
	velocity.y = -jump_velocity

	# Set horizontal velocity based on the direction parameter
	if direction == -1:
		velocity.x = -speed  # Diagonal jump left
		flip_sprite(-1)
	elif direction == 1:
		velocity.x = speed  # Diagonal jump right
		flip_sprite(1)
	else:
		velocity.x = 0  # Neutral jump

	# Transition to jumping state
	transition_to_state(State.JUMPING)

func initiate_attack(attack_type: int) -> void:
	if attack_type == 1:
		current_attack_damage = attack1_dmg
		attack_stun_duration = attack1_stun_duration
		anim.play("attack")
		enable_hitbox("attack")
	elif attack_type == 2:
		current_attack_damage = attack2_dmg
		attack_stun_duration = attack2_stun_duration
		anim.play("attack2")
		enable_hitbox("attack2")
	current_state = State.ATTACKING

# --- Animation Callbacks ---
func on_animation_finished() -> void:
	match anim.animation:
		"attack", "attack2":
			disable_hitboxes()
			current_state = State.IDLE  # Transition back to idle state
			anim.play("idle")
		"stunned":
			pass  # Automatically transition in handle_stunned_state()

func on_animation_frame_changed() -> void:
	var current_animation = anim.animation
	var current_frame = anim.frame
	if hitbox_activation_frames.has(current_animation):
		var attack_info = hitbox_activation_frames[current_animation]
		var hitbox = attack_info["hitbox"]
		var active_frames = attack_info["active_frames"]
		hitbox.disabled = current_frame not in active_frames

# --- Collision Handling ---
func on_hitbox_body_entered(body: Node) -> void:
	if body != self and body.has_method("take_damage"):
		body.take_damage(current_attack_damage, attack_stun_duration)  # Pass stun duration

# --- Damage Handling ---
func take_damage(amount: int, stun_duration: float = 0.0) -> void:
	current_hp -= amount
	emit_signal("damaged", amount)
	if current_hp <= 0:
		die()
	elif stun_duration > 0.0:
		initiate_stun(stun_duration)  # Apply stun if duration is greater than zero

func die() -> void:
	emit_signal("died")
	# Handle death logic (animation, removal, etc.)

func initiate_stun(stun_duration: float) -> void:
	current_state = State.STUNNED
	stun_timer = stun_duration
	anim.play("stunned")

# --- Utility Functions ---
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func flip_sprite(direction: float) -> void:
	if direction > 0:
		anim.flip_h = false
		facing_right = true
	elif direction < 0:
		anim.flip_h = true
		facing_right = false
	# Do not change facing direction for neutral jumps
	flip_hitbox()

func flip_hitbox() -> void:
	slash_attack.scale.x = 1 if facing_right else -1

func enable_hitbox(attack_name: String) -> void:
	var hitbox = hitbox_activation_frames[attack_name]["hitbox"]
	hitbox.disabled = false

func disable_hitboxes() -> void:
	slash_hitbox.call_deferred("set_disabled", true)
	slash_hitbox2.call_deferred("set_disabled", true)

# --- Reset Function ---
func reset(new_position: Vector2) -> void:
	current_hp = max_hp
	position = new_position
	velocity = Vector2.ZERO
	current_state = State.IDLE
	stun_timer = 0.0
	anim.play("idle")
	disable_hitboxes()
