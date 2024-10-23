# projectile.gd
class_name Projectile
extends CharacterBody2D


@export var speed: float = 400
@export var ttl: float = 4

@onready var hitbox: Area2D = $hitbox
@onready var timer: Timer = $Timer

var damage_hit: int
var damage_block: int
var stun_hit_duration: float
var stun_block_duration: float
var pushback: Vector2
var sound_hit: AudioStreamPlayer2D

var spawn_pos: Vector2
var character: Character
var group_name: String = "projectiles"


func _ready() -> void:
	add_to_group(group_name)
	
	global_position = spawn_pos
	
	hitbox.area_entered.connect(on_area_entered)
	
	timer.wait_time = ttl
	timer.timeout.connect(timeout)
	timer.start()
	
	
	if not character.is_opponent_right:
		speed = -speed
		scale.x = -1
	
	velocity.x = speed


func _physics_process(delta: float) -> void:
	move_and_slide()


func timeout():
	remove_from_group(group_name)
	queue_free()
	
	
func on_area_entered(area: Area2D) -> void:
	if area == character.opponent.hurtbox:
		if character.opponent.is_invincible:
			return
		
		if not character.opponent.is_blocking():
			sound_hit.play()
			
		character.opponent.take_damage(
			damage_block if character.opponent.is_blocking() else damage_hit, 
			stun_block_duration if character.opponent.is_blocking() else stun_hit_duration)
		apply_pushback(character.opponent, pushback)
		
		remove_from_group(group_name)
		queue_free()
		
	if area.get_parent() is Projectile:
		remove_from_group(group_name)
		queue_free()


func apply_pushback(opponent: Character, pushback_force: Vector2) -> void:	
	var pushback_direction = 1 if character.is_opponent_right else -1
	if opponent is CharacterBody2D:
		opponent.velocity.x = pushback_direction * pushback_force.x
		opponent.velocity.y = -pushback_force.y
