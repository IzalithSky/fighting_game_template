# attack.gd
class_name Attack
extends Area2D


@export var animation_name: String
@export var animation_offset: Vector2 = Vector2(0, -40)
@export var sound_swing: AudioStreamPlayer2D
@export var sound_hit: AudioStreamPlayer2D
@export var input_name: String

@onready var character: Character = get_parent() as Character

var hitboxes: Dictionary = {}
var hit_time: float = 0


func _ready() -> void:
	load_hitboxes()
	area_entered.connect(on_area_entered)


func load_hitboxes() -> void:
	for node in get_children():
		if node is Hitbox:
			var hitbox_name = node.name
			if hitbox_name != "":
				hitboxes[hitbox_name] = node
				node.disabled = true
				node.visible = false
			else:
				printerr("Hitbox node has no name: ", node.name)


func enter():
	character.play_anim(
		animation_name, 
		animation_offset.x if character.is_opponent_right else -animation_offset.x, 
		animation_offset.y)
		
	if sound_swing:
		sound_swing.play()


func physics(delta: float):
	var is_active: bool = false
	for n in hitboxes:
		var h = n as Hitbox
		if h.time_start >= hit_time and h.time_start + h.duration <= hit_time:
			h.disabled = false
			h.visible = true
			is_active = true
		else:
			h.call_deferred("set_disabled", true)
			h.call_deferred("set_visible", false)
	hit_time += delta
	
	draw_activity(is_active)


func exit():
	hit_time = 0
	for n in hitboxes:
		var h = n as Hitbox
		h.call_deferred("set_disabled", true)
		h.call_deferred("set_visible", false)


func on_area_entered(area: Area2D) -> void:
	if area == character.opponent.hurtbox:
		if character.opponent.is_invincible:
			return
		
		var is_opponent_blocking = character.opponent.is_blocking()
		for n in hitboxes:
			var h = n as Hitbox
			if not h.disabled:
				character.opponent.take_damage(
					h.damage_hit if is_opponent_blocking else h.damage_block,
					h.stun_hit_duration if is_opponent_blocking else h.stun_block_duration)
				
				apply_pushback(character.opponent, h.pushback)
				
				if sound_hit and not character.opponent.is_blocking():
					sound_hit.play()


func apply_pushback(opponent: Character, pushback_force: Vector2) -> void:
	opponent.velocity.x = pushback_force.x * 1 if character.is_opponent_right else -1
	opponent.velocity.y = -pushback_force.y


func draw_activity(is_active: bool):
	var color = Color(1, 0, 0) if is_active else Color(0, 1, 0)
	if character.input_prefix == "p1_":
		character.frame_data_bar.update_top_block_color(color)
	else:
		character.frame_data_bar.update_bot_block_color(color)
