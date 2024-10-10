# attack.gd
class_name Attack
extends Node


@export var damage: int = 0
@export var stun_duration: float = 0
@export var pushback: Vector2 = Vector2.ZERO
@export var hitbox: CollisionShape2D
@export var animation_name: String
@export var duration_startup: float = 0
@export var duration_hit: float = 0
@export var duration_recovery: float = 0

@onready var character: Character = get_parent().get_parent() as Character
