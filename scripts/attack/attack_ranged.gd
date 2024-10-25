# attack_ranged.gd
class_name AttackRanged
extends Attack


@export var projectile_scene: PackedScene

@onready var spawn_point: Hitbox = $spawn_point

var launched: bool = false


func enter():
	super()
	launched = false


func physics(delta: float):
	var is_active: bool = false
	
	if not launched and frames >= spawn_point.frame_start:
		is_active = true
		launch()
		launched = true
	
	frames += 1
	
	draw_activity(is_active)


func on_area_entered(area: Area2D) -> void:
	pass


func launch():
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.damage_hit = spawn_point.damage_hit
	projectile.damage_block = spawn_point.damage_block
	projectile.stun_hit_duration = spawn_point.stun_hit_duration
	projectile.stun_block_duration = spawn_point.stun_block_duration
	projectile.sound_hit = sound_hit
	projectile.pushback = spawn_point.pushback
	projectile.character = character
	projectile.spawn_pos = spawn_point.global_position

	var world_root = get_tree().root
	world_root.add_child(projectile)
