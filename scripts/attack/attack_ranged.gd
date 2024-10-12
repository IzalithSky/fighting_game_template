# attack_ranged.gd
class_name AttackRanged
extends Attack


@export var projectile_scene: PackedScene


func enter_hit():
	super()
	
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.damage = damage
	projectile.stun_duration = stun_duration
	projectile.sound_hit = sound_hit
	projectile.pushback = pushback
	projectile.character = character
	projectile.spawn_pos = hitbox.global_position
	
	var world_root = get_tree().root.get_child(0)
	world_root.add_child(projectile)
	
	print(1)
	
	
func on_area_entered(area: Area2D) -> void:
	pass
