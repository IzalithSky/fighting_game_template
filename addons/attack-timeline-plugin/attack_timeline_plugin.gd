@tool
extends EditorPlugin

var timeline_control: Control

func _enter_tree() -> void:
	timeline_control = preload("res://addons/attack-timeline-plugin/attack_timeline.tscn").instantiate()
	add_control_to_bottom_panel(timeline_control, "Attack Timeline")
	var selection = get_editor_interface().get_selection()
	selection.connect("selection_changed", on_selection_changed)

func _exit_tree() -> void:
	remove_control_from_bottom_panel(timeline_control)
	var selection = get_editor_interface().get_selection()
	if selection.is_connected("selection_changed", on_selection_changed):
		selection.disconnect("selection_changed", on_selection_changed)

func on_selection_changed():
	var selection = get_editor_interface().get_selection()
	var selected_nodes = selection.get_selected_nodes()
	timeline_control.refresh_selection(selected_nodes)
