extends CharacterBody2D

# --- Exported Variables ---
@export var speed: float = 250.0
@export var jump_velocity: float = 400.0
@export var max_hp: int = 100

@export var input_prefix: String = "p1_"  # To switch between p1_ and p2_
@export var gravity: float = 1200.0  # Gravity strength
@export var attack_data_file: String = "res://attack_data.json"  # Path to the JSON file

# New optional variables
@export var opponent: NodePath  # Pointer to the opponent
@export var always_face_opponent: bool = true  # Whether to always face the opponent

# --- Signals ---
signal damaged(amount: int)
signal died()

# --- Enumerations ---
enum State {
	IDLE,
	WALKING,
	JUMPING,
	ATTACKING,
	STUNNED,
	BLOCKING
}

# --- Internal Variables ---
var current_hp: int = max_hp
var current_state: State = State.IDLE
var facing_right: bool = true  # Direction the character is facing
var stun_timer: float = 0.0  # Timer for stun duration
var current_attack_damage: int = 0  # Damage of current attack
var attack_stun_duration: float = 0.0  # Stun duration of current attack
var current_pushback_force: float = 0.0  # Pushback force of current attack
var current_vertical_pushback_force: float = 0.0  # Vertical pushback force of current attack
var current_attack_data: Dictionary = {}  # Dictionary to hold data for the current attack
var opponent_instance: Node = null  # Reference to the opponent node

# --- Node References ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox = $hurtbox/collider
@onready var slash_attack = $hitboxes
@onready var slash_hitbox1 = $hitboxes/slash_hitbox1  # Adjust this to the correct node path
@onready var slash_hitbox2 = $hitboxes/slash_hitbox2  # Adjust this to the correct node path

# --- Attack Data ---
var attack_data: Dictionary = {}

# --- Lifecycle Methods ---
func _ready() -> void:
	# Load the attack data from the JSON file
	load_attack_data()

	# Initialize hitboxes and disable them
	disable_hitboxes()

	# Connect signals
	anim.connect("animation_finished", on_animation_finished)
	anim.connect("frame_changed", on_animation_frame_changed)
	slash_attack.connect("body_entered", on_hitbox_body_entered)

	# Load opponent reference if provided
	if opponent != null:
		opponent_instance = get_node(opponent)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_state(delta)
	
	# Make sure the player faces the opponent if required
	if always_face_opponent and opponent_instance:
		face_opponent()
	
	move_and_slide()

# --- Load Attack Data ---
func load_attack_data() -> void:
	# Load the JSON file
	var file = FileAccess.open(attack_data_file, FileAccess.READ)
	if file:
		var json_data = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_data)  # Parse returns an integer (OK or error code)

		# Check if parsing was successful
		if error == OK:
			attack_data = json.get_data()  # Use get_data() to access the parsed JSON data
			# Set up hitbox paths to nodes based on the strings from JSON
			for attack_name in attack_data.keys():
				var hitbox_path = attack_data[attack_name]["hitbox_path"]  # Get the hitbox path string
				var hitbox_node = get_node(hitbox_path)  # Use get_node() to find the node by path
				if hitbox_node:
					attack_data[attack_name]["hitbox"] = hitbox_node  # Store the node reference
		else:
			# Print detailed error message
			print("Error parsing JSON at line", json.get_error_line(), ":", json.get_error_message())
	else:
		print("Failed to load file:", attack_data_file)

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
		State.BLOCKING:
			handle_blocking_state(delta)

# --- Input Handling (Prioritize Attack) ---
func handle_input(delta: float) -> bool:
	if Input.is_action_just_pressed(input_prefix + "attack"):
		initiate_attack("attack1")
		return true
	elif Input.is_action_just_pressed(input_prefix + "attack2"):
		initiate_attack("attack2")
		return true
	elif Input.is_action_just_pressed(input_prefix + "block") and is_on_floor():
		transition_to_state(State.BLOCKING)
		return true
	elif Input.is_action_just_pressed(input_prefix + "jump"):
		var jump_direction = 0
		if Input.is_action_pressed(input_prefix + "left") and not Input.is_action_pressed(input_prefix + "right"):
			jump_direction = -1
		elif Input.is_action_pressed(input_prefix + "right") and not Input.is_action_pressed(input_prefix + "left"):
			jump_direction = 1
		initiate_jump(jump_direction)
		return true
	return false

# --- Idle State Handling ---
func handle_idle_state(delta: float) -> void:
	if handle_input(delta):
		return  # Exit early if an input is handled

	var direction = Input.get_axis(input_prefix + "left", input_prefix + "right")
	if direction != 0:
		transition_to_state(State.WALKING, direction)
	else:
		velocity.x = 0
		anim.play("idle")

# --- Walking State Handling ---
func handle_walking_state(delta: float) -> void:
	if handle_input(delta):
		return  # Exit early if an input is handled

	var direction = Input.get_axis(input_prefix + "left", input_prefix + "right")
	if direction != 0:
		velocity.x = direction * speed
		anim.play("walk")
		flip_sprite(direction)
	else:
		transition_to_state(State.IDLE)

# --- Jumping State Handling ---
func handle_jumping_state(delta: float) -> void:
	if handle_input(delta):
		return  # Exit early if an input is handled

	if is_on_floor():
		velocity.y = 0
		transition_to_state(State.IDLE)

# --- Attacking State Handling ---
func handle_attacking_state(delta: float) -> void:
	if is_on_floor():
		velocity.x = 0  # Lock movement on the ground

# --- Stunned State Handling ---
func handle_stunned_state(delta: float) -> void:
	stun_timer -= delta
	if stun_timer <= 0.0:
		transition_to_state(State.IDLE)

# --- Blocking State Handling ---
func handle_blocking_state(delta: float) -> void:
	if handle_input(delta):
		return  # Exit early if an input is handled

	# Remain in blocking state as long as the block input is held and the player is on the ground
	if Input.is_action_pressed(input_prefix + "block") and is_on_floor():
		velocity.x = 0  # Character should not move while blocking
		anim.play("block")  # Play blocking animation

		# Allow movement (walking) while blocking
		var direction = Input.get_axis(input_prefix + "left", input_prefix + "right")
		if direction != 0:
			velocity.x = direction * speed * 0.5  # Move at reduced speed while blocking
			flip_sprite(direction)
		
	else:
		transition_to_state(State.IDLE)  # Stop blocking if block input is released or player is airborne

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
		State.BLOCKING:
			anim.play("block")

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

func initiate_attack(attack_name: String) -> void:
	current_attack_data = attack_data[attack_name]
	current_attack_damage = current_attack_data["damage"]
	attack_stun_duration = current_attack_data["stun_duration"]
	current_pushback_force = current_attack_data.get("pushback_force", 0)  # Default to 0 if not defined
	current_vertical_pushback_force = current_attack_data.get("vertical_pushback_force", 0)  # Default to 0 if not defined
	anim.play(attack_name)
	enable_hitbox(attack_name)
	current_state = State.ATTACKING

# --- Face Opponent Logic ---
func face_opponent() -> void:
	if opponent_instance != null:
		var opponent_pos = opponent_instance.global_position
		if opponent_pos.x > global_position.x and not facing_right:
			flip_sprite(1)
		elif opponent_pos.x < global_position.x and facing_right:
			flip_sprite(-1)

# --- Animation Callbacks ---
func on_animation_finished() -> void:
	match anim.animation:
		"attack1", "attack2":
			disable_hitboxes()
			current_state = State.IDLE  # Transition back to idle state
			anim.play("idle")
		"stunned":
			pass  # Automatically transition in handle_stunned_state()

func on_animation_frame_changed() -> void:
	var current_animation = anim.animation
	var current_frame = anim.frame
	
	if attack_data.has(current_animation):
		var attack_info = attack_data[current_animation]
		var hitbox = attack_info["hitbox"]
		var active_frames = attack_info["active_frames"]

		# Check if the current frame is within the active frames
		if current_frame in active_frames and hitbox.disabled:
			hitbox.disabled = false  # Activate hitbox once
		elif current_frame > active_frames[-1] and not hitbox.disabled:
			hitbox.disabled = true  # Deactivate hitbox after the active frame window

# --- Collision Handling ---
func on_hitbox_body_entered(body: Node) -> void:
	if body != self and body.has_method("take_damage"):
		# Apply damage and stun to the target
		body.take_damage(current_attack_damage, attack_stun_duration)
		
		# Apply pushback to the target
		apply_pushback(body)

func apply_pushback(body: Node) -> void:
	# Calculate pushback direction based on which side of the player the opponent is
	var pushback_direction = 1 if facing_right else -1
	
	# Apply pushback force to the target's velocity
	if body is CharacterBody2D:
		body.velocity.x = pushback_direction * current_pushback_force
		body.velocity.y = -current_vertical_pushback_force

# --- Damage Handling ---
func take_damage(amount: int, stun_duration: float = 0.0) -> void:
	var actual_damage = amount
	var actual_stun_duration = stun_duration
	
	if current_state == State.BLOCKING:
		# Reduce damage by 80%, but minimum damage should be 1
		actual_damage = max(1, int(amount * 0.2))
		# Reduce stun duration by 60%
		actual_stun_duration = stun_duration * 0.6
	
	current_hp -= actual_damage
	emit_signal("damaged", actual_damage)

	if current_hp <= 0:
		die()
	elif actual_stun_duration > 0.0:
		initiate_stun(actual_stun_duration)  # Apply reduced stun if blocking

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
	var hitbox = attack_data[attack_name]["hitbox"]
	hitbox.disabled = false

func disable_hitboxes() -> void:
	slash_hitbox1.call_deferred("set_disabled", true)
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
