# move.gd
class_name Move
extends Node


@export var time_start: float = 0
@export var duration: float = 0

@export var reset_velocity: bool = false
@export var freeze_on_floor: bool = true
@export var impulse: Vector2 = Vector2.ZERO
@export var teleport: Vector2 = Vector2.ZERO

@onready var character: Character = get_parent().get_parent() as Character


func physics(delta: float) -> void:
	if reset_velocity:
		character.velocity = Vector2.ZERO
	if freeze_on_floor and character.is_on_floor():
		character.velocity.x = 0
	if impulse != Vector2.ZERO:
		character.velocity += adjust_direction(impulse)
	if teleport != Vector2.ZERO:
		character.position += adjust_direction(teleport)


func adjust_direction(v: Vector2) -> Vector2:
	return Vector2(v.x, -v.y) if character.is_opponent_right else Vector2(-v.x, -v.y)
