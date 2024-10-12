class_name Projectile
extends CharacterBody2D


@export var speed: float = 400
@export var ttl: float = 4

@onready var hitbox: Area2D = $hitbox
@onready var timer: Timer = $Timer

var damage: int
var stun_duration: float
var pushback: Vector2
var sound_hit: AudioStreamPlayer2D

var spawn_pos: Vector2
var character: Character


func _ready() -> void:
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
	queue_free()
	
	
func on_area_entered(area: Area2D) -> void:
	if area == character.opponent.hurtbox:
		if not character.opponent.is_blocking():
			sound_hit.play()
			
		character.opponent.take_damage(damage, stun_duration)
		apply_pushback(character.opponent, pushback)
		
		queue_free()


func apply_pushback(opponent: Character, pushback_force: Vector2) -> void:	
	var pushback_direction = 1 if character.is_opponent_right else -1
	if opponent is CharacterBody2D:
		opponent.velocity.x = pushback_direction * pushback_force.x
		opponent.velocity.y = -pushback_force.y
