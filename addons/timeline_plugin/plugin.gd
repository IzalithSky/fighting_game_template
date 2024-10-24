# plugin.gd
extends EditorPlugin

var timeline_editor

func _enter_tree():
	# Load the timeline editor UI
	timeline_editor = preload("res://addons/timeline_plugin/timeline_editor.tscn").instantiate()
	
	# Add the timeline editor as a dock in the editor
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, timeline_editor)
	timeline_editor.hide()  # Hidden by default
	
	# Connect to the selection changed signal to update the timeline
	get_editor_interface().get_selection().selection_changed.connect(on_selection_changed)

	# Optionally, add a menu item or a toolbar button to toggle the timeline
	# For simplicity, we'll show the timeline when an Attack node is selected

func _exit_tree():
	remove_control_from_docks(timeline_editor)
	timeline_editor.queue_free()  # Manually free the timeline editor instance
	get_editor_interface().get_selection().selection_changed.disconnect(on_selection_changed)

func on_selection_changed():
	var selected = get_editor_interface().get_selection().get_selected_nodes()
	if selected.size() == 1 and selected[0] is Attack:
		timeline_editor.set_attack(selected[0])
		timeline_editor.show()
	else:
		timeline_editor.hide()
