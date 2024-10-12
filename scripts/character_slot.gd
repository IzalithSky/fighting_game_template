# character_slot.gd
class_name CharacterSlot
extends Control

func _ready():
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	
	focus_entered.connect(on_focus_entered)
	focus_exited.connect(on_focus_exited)

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
