extends CharacterBody2D

@export var speed = 250.0
@export var jump_velocity = 400.0
@export var max_hp = 100
var current_hp = max_hp

@onready var anim = $AnimatedSprite2D
@onready var hurtbox = $hurtbox/collider
@onready var slash_attack = $hitboxes
@onready var slash_hitbox = $hitboxes/slash_hitbox  # Hitbox for attack 1
@onready var slash_hitbox2 = $hitboxes/slash_hitbox2  # Hitbox for attack 2
@export var input_prefix = "p1_"  # To switch between p1_ and p2_

var is_attacking = false
var facing_right = true  # Keep track of which direction the character is facing

# Define custom signal for taking damage
signal damaged(amount)
signal died()

func _ready() -> void:
	# Ensure both hitboxes are disabled initially
	slash_hitbox.disabled = true
	slash_hitbox2.disabled = true
	current_hp = max_hp

# Function to receive damage
func take_damage(amount: int):
	current_hp -= amount
	emit_signal("damaged", amount)  # Emit signal when damaged
	if current_hp <= 0:
		die()

# Function to handle death
func die():
	#queue_free()  # Placeholder: you can add a death animation or game over logic here
	emit_signal("died")

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed(input_prefix + "jump") and is_on_floor():
		velocity.y = -jump_velocity

	# Handle attack 1
	if Input.is_action_just_pressed(input_prefix + "attack") and not is_attacking:
		is_attacking = true
		anim.play("attack")  # Play attack animation
		# Disable movement and enable slash attack hitbox for attack 1
		await _handle_attack_frames()

	# Handle attack 2
	elif Input.is_action_just_pressed(input_prefix + "attack2") and not is_attacking:
		is_attacking = true
		anim.play("attack2")  # Play attack2 animation
		# Disable movement and enable slash attack hitbox for attack 2
		await _handle_attack2_frames()

	# If attacking, don't move or play other animations.
	if not is_attacking:
		# Get the input direction and handle the movement/deceleration.
		var direction := Input.get_axis(input_prefix + "left", input_prefix + "right")
		if direction != 0:
			velocity.x = direction * speed
			anim.play("walk")  # Play walk animation

			# Flip the sprite and hitbox depending on the direction
			if direction > 0:
				anim.flip_h = false  # Facing right
				facing_right = true
			elif direction < 0:
				anim.flip_h = true   # Facing left
				facing_right = false

			# Flip both hitboxes along with the sprite
			flip_hitbox()

		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			if is_on_floor():  # Only play idle if on the floor
				anim.play("idle")  # Play idle animation

	move_and_slide()

# Flip the hitbox based on the direction the character is facing
func flip_hitbox() -> void:
	if facing_right:
		# Set hitbox to the default right position
		slash_attack.position.x = abs(slash_attack.position.x)
		slash_hitbox2.position.x = abs(slash_hitbox2.position.x)
	else:
		# Flip hitbox to the left by inverting its position
		slash_attack.position.x = -abs(slash_attack.position.x)
		slash_hitbox2.position.x = -abs(slash_hitbox2.position.x)

# Handle enabling/disabling the slash_hitbox for attack 1 during specific frames of the attack animation
func _handle_attack_frames() -> void:
	# Wait until frame 1 of the animation
	await anim.frame_changed
	if anim.frame == 1:
		slash_hitbox.disabled = false  # Enable attack hitbox

	# Wait for frame 2 of the animation
	await anim.frame_changed
	if anim.frame == 2:
		slash_hitbox.disabled = false  # Keep attack hitbox enabled

	# Wait for frame 3 of the animation to disable attack hitbox
	await anim.frame_changed
	if anim.frame == 3:
		slash_hitbox.disabled = true  # Disable attack hitbox

	# End the attack after the animation finishes
	await anim.animation_finished
	is_attacking = false

# Handle enabling/disabling the slash_hitbox2 for attack 2 during specific frames of the attack2 animation
func _handle_attack2_frames() -> void:
	# Wait until frame 1 of the animation
	await anim.frame_changed
	if anim.frame == 1:
		slash_hitbox2.disabled = true  # Keep attack 2 hitbox disabled

	# Wait for frame 2 of the animation
	await anim.frame_changed
	if anim.frame == 2:
		slash_hitbox2.disabled = false  # Enable attack 2 hitbox

	# Wait for frame 3 of the animation
	await anim.frame_changed
	if anim.frame == 3:
		slash_hitbox2.disabled = false  # Keep hitbox enabled

	# Wait for frame 4 of the animation to disable attack 2 hitbox
	await anim.frame_changed
	if anim.frame == 4:
		slash_hitbox2.disabled = true  # Disable attack 2 hitbox

	# End the attack after the animation finishes
	await anim.animation_finished
	is_attacking = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != self:  # Make sure the character doesn't hit themselves
		body.take_damage(10)  # Adjust damage as needed
