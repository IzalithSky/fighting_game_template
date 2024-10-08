# bot_parameters.gd
class_name BotParameters
extends Node


@onready var character: Character = get_parent().get_parent() as Character

@export var idle_only: bool = false
@export var always_block: bool = false
@export var jump_distance: float = 256
@export var attack_distance: float = 50

var opponent_distance: float = 1000


func _physics_process(delta: float) -> void:
	opponent_distance = abs(character.position.x - character.opponent.position.x)


func is_in_jump_distance() -> bool:
	return opponent_distance >= jump_distance
	
	
func is_in_attack_distance() -> bool:
	return opponent_distance <= attack_distance
