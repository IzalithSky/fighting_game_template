# attack.gd
class_name Attack
extends Area2D


@export var animation_name: String
@export var mp_cost: int = 0
@export var animation_offset: Vector2 = Vector2(0, -40)
@export var sound_swing: AudioStreamPlayer2D
@export var sound_hit: AudioStreamPlayer2D
@export var duration: float

@onready var character: Character = get_parent() as Character
@onready var earliest_attack_start: float = duration
@onready var hitbox_probe: ShapeCast2D = ShapeCast2D.new()

var hitboxes: Array[Hitbox] = []
var moves: Array[Move] = []
var hit_time: float = 0
var latest_attack_end: float = 0
var is_recovery: bool = false
var is_startup: bool = false


func _ready() -> void:
	load_hitboxes()
	load_moves()
	area_entered.connect(on_area_entered)
	
	hitbox_probe.exclude_parent = true
	hitbox_probe.enabled = false
	hitbox_probe.visible = false
	hitbox_probe.target_position = Vector2.ZERO
	hitbox_probe.collision_mask = collision_mask
	hitbox_probe.collide_with_bodies = false
	hitbox_probe.collide_with_areas = true
	hitbox_probe.modulate = Color.BLUE_VIOLET
	add_child(hitbox_probe)


func _draw():
	draw_line(Vector2.ZERO, hitbox_probe.target_position, Color.BLUE_VIOLET, 2)


func is_enemy_in_attack_range() -> bool:
	hitbox_probe.add_exception(character.hurtbox)
	hitbox_probe.enabled = true
	hitbox_probe.visible = true
	
	var extrapolated_target = character.velocity * earliest_attack_start
	hitbox_probe.target_position = extrapolated_target
	
	for h in hitboxes:
		hitbox_probe.shape = h.shape
		hitbox_probe.global_position = h.global_position
		hitbox_probe.scale = h.scale
		hitbox_probe.force_shapecast_update()
		
		if hitbox_probe.is_colliding():
			hitbox_probe.enabled = false
			hitbox_probe.visible = false
			return true
	
	hitbox_probe.enabled = false
	hitbox_probe.visible = false
	return false


func load_hitboxes() -> void:
	for node in get_children():
		if node is Hitbox:
			var h = node as Hitbox
			hitboxes.append(h)
			h.disabled = true
			h.visible = false
			if earliest_attack_start > h.time_start:
				earliest_attack_start = h.time_start
			if latest_attack_end < h.time_start + h.duration:
				latest_attack_end = h.time_start + h.duration


func load_moves() -> void:
	for node in get_children():
		if node is Move:
			moves.append(node as Move)


func enter() -> void:
	character.play_anim(
		animation_name, 
		animation_offset.x if character.is_opponent_right else -animation_offset.x, 
		animation_offset.y)
	
	if sound_swing:
		sound_swing.play()
		
	is_startup = true
	is_recovery = false


func physics(delta: float) -> void:
	var is_active: bool = false
	
	# Handle Hitboxes
	for h in hitboxes:
		if hit_time >= h.time_start and hit_time <= h.time_start + h.duration:
			h.disabled = false
			h.visible = true
			is_active = true
		else:
			h.call_deferred("set_disabled", true)
			h.call_deferred("set_visible", false)
	
	# Handle Moves
	for m in moves:
		if hit_time >= m.time_start and hit_time <= m.time_start + m.duration:
			if hit_time >= m.time_start and not m.has_entered:
				m.enter()
			m.physics(delta)
	
	
	if hit_time >= earliest_attack_start:
		is_startup = false
	
	if hit_time >= latest_attack_end:
		is_recovery = true
		
	if hit_time < latest_attack_end:
		character.draw_activity(is_active)
	else:
		character.draw_recovery()

	hit_time += delta

func exit() -> void:
	hit_time = 0
	for n in hitboxes:
		var h = n as Hitbox
		h.call_deferred("set_disabled", true)
		h.call_deferred("set_visible", false)
	
	# Reset all moves
	for m in moves:
		m.reset_move()


func on_area_entered(area: Area2D) -> void:
	if area == character.opponent.hurtbox:
		if character.opponent.is_invincible:
			return
		
		var is_opponent_blocking = character.opponent.is_blocking()
		for h in hitboxes:
			if not h.disabled:
				character.opponent.take_damage(
					h.damage_block if is_opponent_blocking else h.damage_hit,
					h.stun_block_duration if is_opponent_blocking else h.stun_hit_duration,
					sound_hit)
				
				apply_pushback(character.opponent, h.pushback)


func apply_pushback(opponent: Character, pushback_force: Vector2) -> void:
	opponent.velocity.x = pushback_force.x * (1 if character.is_opponent_right else -1)
	opponent.velocity.y = -pushback_force.y
