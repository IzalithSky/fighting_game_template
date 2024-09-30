extends CharacterBody2D

@export var speed = 250.0
@export var jump_velocity = 400.0
@export var max_hp = 100

@export var attack1_dmg = 10
@export var attack1_stun_duration: float = 0.5  # Stun duration for attack 1 in seconds
@export var attack2_dmg = 20
@export var attack2_stun_duration: float = 1.0  # Stun duration for attack 2 in seconds

var current_hp = max_hp

@onready var anim = $AnimatedSprite2D
@onready var hurtbox = $hurtbox/collider
@onready var slash_attack = $hitboxes
@onready var slash_hitbox = $hitboxes/slash_hitbox  # Hitbox for attack 1
@onready var slash_hitbox2 = $hitboxes/slash_hitbox2  # Hitbox for attack 2

@export var input_prefix = "p1_"  # To switch between p1_ and p2_
@export var gravity: float = 1200.0  # Define gravity

# --- Signals ---
signal damaged(amount)
signal died()

# --- State Definitions ---
enum State {
	IDLE,
	WALKING,
	JUMPING,
	ATTACKING,
	STUNNED
}

var current_state: State = State.IDLE

# --- Internal Variables ---
var facing_right: bool = true  # Direction the character is facing
var stun_timer: float = 0.0  # Timer for stun duration
var attack_stun_duration: float = 0.0  # Duration of stun after attack
var current_attack_damage: int = 0  # Damage of current attack

# --- Hitbox Activation Frames ---
var hitbox_activation_frames: Dictionary = {}

func _ready() -> void:
	# Initialize hitboxes
	disable_hitboxes()
	
	# Initialize hitbox activation frames
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
	
	# Connect animation signals
	anim.connect("animation_finished", Callable(self, "_on_animation_finished"))
	anim.connect("frame_changed", Callable(self, "_on_animation_frame_changed"))
	slash_attack.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))

# --- Damage Handling ---
func take_damage(amount: int) -> void:
	current_hp -= amount
	emit_signal("damaged", amount)
	if current_hp <= 0:
		die()

func die() -> void:
	emit_signal("died")
	# Optionally, handle death animation or removal here

# --- FSM Logic ---
func _physics_process(delta: float) -> void:
	# Apply gravity if the character is not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta

	# FSM handling
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
	
	# Apply movement
	move_and_slide()

# --- State Handlers ---
func handle_idle_state(delta: float) -> void:
	# Check for movement input
	var direction = Input.get_axis(input_prefix + "left", input_prefix + "right")
	if direction != 0:
		current_state = State.WALKING
		velocity.x = direction * speed
		anim.play("walk")
		flip_sprite(direction)
	else:
		velocity.x = 0
		anim.play("idle")
	
	# Check for jump
	if Input.is_action_just_pressed(input_prefix + "jump"):
		initiate_jump()
	
	# Check for attacks
	if Input.is_action_just_pressed(input_prefix + "attack"):
		initiate_attack(1)
	elif Input.is_action_just_pressed(input_prefix + "attack2"):
		initiate_attack(2)

func handle_walking_state(delta: float) -> void:
	var direction = Input.get_axis(input_prefix + "left", input_prefix + "right")
	if direction != 0:
		velocity.x = direction * speed
		anim.play("walk")
		flip_sprite(direction)
	else:
		current_state = State.IDLE
		velocity.x = 0
		anim.play("idle")
	
	# Check for jump
	if Input.is_action_just_pressed(input_prefix + "jump"):
		initiate_jump()
	
	# Check for attacks
	if Input.is_action_just_pressed(input_prefix + "attack"):
		initiate_attack(1)
	elif Input.is_action_just_pressed(input_prefix + "attack2"):
		initiate_attack(2)

func handle_jumping_state(delta: float) -> void:
	# Gravity is already applied in _physics_process
	
	# Allow for natural landing detection
	if is_on_floor():
		velocity.y = 0
		current_state = State.IDLE
		anim.play("idle")
	
	# Allow attacks in air
	if Input.is_action_just_pressed(input_prefix + "attack"):
		initiate_attack(1)
	elif Input.is_action_just_pressed(input_prefix + "attack2"):
		initiate_attack(2)

func handle_attacking_state(delta: float) -> void:
	# During attacking, restrict movement based on ground or air
	if is_on_floor():
		velocity.x = 0  # Interrupt ground movement
	# In air, retain velocity.x (no movement control)
	# State transition is handled via animation_finished signal

func handle_stunned_state(delta: float) -> void:
	stun_timer -= delta
	if stun_timer <= 0.0:
		current_state = State.IDLE
		anim.play("idle")
	# During stun, no movement or actions are allowed

# --- Helper Functions ---
func initiate_jump() -> void:
	velocity.y = -jump_velocity
	var direction = Input.get_axis(input_prefix + "left", input_prefix + "right")
	if direction > 0:
		velocity.x = speed
	elif direction < 0:
		velocity.x = -speed
	current_state = State.JUMPING
	anim.play("idle")  # Ensure you have a 'jump' animation or replace with an existing one
	#anim.play("jump")  # Ensure you have a 'jump' animation or replace with an existing one

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

func initiate_stun() -> void:
	current_state = State.STUNNED
	stun_timer = attack_stun_duration
	anim.play("idle")  # Ensure you have a 'stunned' animation
	#anim.play("stunned")  # Ensure you have a 'stunned' animation

func flip_sprite(direction: float) -> void:
	if direction > 0:
		anim.flip_h = false
		facing_right = true
	elif direction < 0:
		anim.flip_h = true
		facing_right = false
	flip_hitbox()

func flip_hitbox() -> void:
	if facing_right:
		slash_attack.scale.x = 1
	else:
		slash_attack.scale.x = -1

func enable_hitbox(attack_name: String) -> void:
	var hitbox = hitbox_activation_frames[attack_name]["hitbox"]
	hitbox.disabled = false

func disable_hitboxes() -> void:
	slash_hitbox.call_deferred("set_disabled", true)
	slash_hitbox2.call_deferred("set_disabled", true)

# --- Collision Handling ---
func _on_hitbox_body_entered(body: Node) -> void:
	if body != self and body.has_method("take_damage"):
		body.take_damage(current_attack_damage)

# --- Animation Callbacks ---
func _on_animation_finished() -> void:
	match anim.animation:
		"attack", "attack2":
			disable_hitboxes()
			initiate_stun()
		"stunned":
			# Transition handled in handle_stunned_state()
			pass
		# Add other animations if necessary

func _on_animation_frame_changed() -> void:
	var current_animation = anim.animation
	var current_frame = anim.frame
	
	# Activate hitbox based on current frame
	if hitbox_activation_frames.has(current_animation):
		var attack_info = hitbox_activation_frames[current_animation]
		var hitbox = attack_info["hitbox"]
		var active_frames = attack_info["active_frames"]

		# Activate hitbox only during the active frames
		if current_frame in active_frames:
			hitbox.disabled = false  # Activate hitbox
		else:
			hitbox.disabled = true  # Deactivate hitbox

# --- Reset Function ---
func reset(new_position: Vector2) -> void:
	# Reset health
	current_hp = max_hp

	# Reset position
	position = new_position

	# Reset velocity and state
	velocity = Vector2.ZERO
	current_state = State.IDLE
	stun_timer = 0.0

	# Reset animations and hitboxes
	anim.play("idle")
	disable_hitboxes()
