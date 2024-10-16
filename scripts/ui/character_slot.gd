# character_slot.gd
class_name CharacterSlot
extends Control


var current_character_scene: PackedScene


func _ready():
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	
	focus_entered.connect(on_focus_entered)
	focus_exited.connect(on_focus_exited)


func assign_character(character_data: Dictionary):
	current_character_scene = load(character_data["scene_path"])
	$NameLabel.text = character_data["name"]
	
	var character_instance = current_character_scene.instantiate()
	var animated_sprite = character_instance.get_node("Animations") 
	var sprite_frames: SpriteFrames = animated_sprite.sprite_frames
	var frame_texture = sprite_frames.get_frame_texture("idle", 0)
	$CharacterTextureRect.texture = frame_texture


func on_mouse_entered():
	set_blinking(true)


func on_mouse_exited():
	set_blinking(false)


func on_focus_entered():
	set_blinking(true)


func on_focus_exited():
	set_blinking(false)


func set_blinking(is_blinking: bool):
	var shader_material = $BottomColorRect.material as ShaderMaterial
	shader_material.set("shader_param/is_blinking", is_blinking)
