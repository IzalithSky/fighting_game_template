# box.gd
extends Control


# Types: "Move" or "Hitbox"
var box_type: String = "Move"

# Reference to the data instance (Move or Hitbox)
var data_instance = null

# Constants
const BOX_HEIGHT = 30
const TIME_SCALE = 50  # Should match TimelineEditor

# UI Elements
@onready var panel = $Panel
@onready var label = $Panel/Label

# Dragging state
var dragging = false
var drag_offset = Vector2.ZERO


func set_data(instance, type: String, time_scale: float):
	data_instance = instance
	box_type = type
	# Set position and size based on start_time and duration
	position.x = instance.time_start * time_scale
	size.x = instance.duration * time_scale
	size.y = BOX_HEIGHT
	# Set visual style based on type
	if box_type == "Move":
		panel.modulate = Color(0.5, 0.7, 1, 0.8)
	elif box_type == "Hitbox":
		panel.modulate = Color(1, 0.5, 0.5, 0.8)
	# Update label
	update_label()


func update_label():
	if box_type == "Move":
		label.text = "Move\nStart: {:.2f}s\nDuration: {:.2f}s".format(data_instance.time_start, data_instance.duration)
	elif box_type == "Hitbox":
		label.text = "Hitbox\nStart: {:.2f}s\nDuration: {:.2f}s".format(data_instance.time_start, data_instance.duration)


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = event.position
				grab_click_focus()
			else:
				dragging = false
	elif event is InputEventMouseMotion and dragging:
		var new_x = position.x + event.relative.x
		new_x = clamp(new_x, 0, get_parent().size.x - size.x)
		position.x = new_x
		# Update the data_instance's start_time
		var new_start_time = new_x / TIME_SCALE
		data_instance.time_start = new_start_time
		update_label()


func _show_context_menu():
	var menu = PopupMenu.new()
	add_child(menu)
	menu.id_pressed.connect(on_menu_option_selected)
	menu.add_item("Delete")
	menu.popup_(get_global_mouse_position())
	menu.show()


func on_menu_option_selected(id):
	if id == 0:  # Delete option
		if box_type == "Move":
			var attack = get_tree().current_scene  # Adjust as needed
			attack.moves.erase(data_instance)
		elif box_type == "Hitbox":
			var attack = get_tree().current_scene  # Adjust as needed
			attack.hitboxes.erase(data_instance)
		queue_free()
