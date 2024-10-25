# hitbox.gd
class_name Hitbox
extends CollisionShape2D


@export var frame_start: int = 0
@export var duration: int = 0

@export var damage_hit: int = 0
@export var damage_block: int = 0
@export var stun_hit_duration: int = 0
@export var stun_block_duration: int = 0
@export var pushback: Vector2 = Vector2.ZERO

@onready var character: Character = get_parent().get_parent() as Character


func _ready() -> void:
	disabled = true
	visible = false
