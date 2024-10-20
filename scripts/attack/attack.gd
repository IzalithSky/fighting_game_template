# attack.gd
class_name Attack
extends Area2D


@export var damage: int = 0
@export var stun_hit_duration: float = 0
@export var stun_block_duration: float = 0
@export var pushback: Vector2 = Vector2.ZERO
@export var animation_name: String
@export var animation_offset: Vector2 = Vector2(0, -40)
@export var sound_swing: AudioStreamPlayer2D
@export var sound_hit: AudioStreamPlayer2D
@export var input_name: String
@export var duration_startup: float = 0
@export var duration_hit: float = 0
@export var duration_recovery: float = 0

@onready var character: Character = get_parent() as Character
@onready var hitbox: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	area_entered.connect(on_area_entered)
	hitbox.disabled = true


func enter_startup():
	character.play_anim(animation_name, animation_offset.x, animation_offset.y)
	sound_swing.play()


func exit_startup():
	pass
	
	
func physics_startup():
	do_physics()


func enter_hit():
	hitbox.disabled = false


func physics_hit():
	do_physics()


func exit_hit():
	hitbox.call_deferred("set_disabled", true)


func physics_recovery():
	do_physics()


func enter_recovery():
	pass


func exit_recovery():
	pass


func do_physics():
	if character.is_on_floor():
		character.velocity.x = 0
		character.velocity.y = 0


func on_area_entered(area: Area2D) -> void:
	if area == character.opponent.hurtbox:
		if character.opponent.is_invincible:
			return
		
		if not character.opponent.is_blocking():
			sound_hit.play()
			
		character.opponent.take_damage(damage, 
			stun_block_duration if character.opponent.is_blocking() else stun_hit_duration)
		apply_pushback(character.opponent, pushback)


func apply_pushback(opponent: Character, pushback_force: Vector2) -> void:	
	var pushback_direction = 1 if character.is_opponent_right else -1
	if opponent is CharacterBody2D:
		opponent.velocity.x = pushback_direction * pushback_force.x
		opponent.velocity.y = -pushback_force.y
