@tool
extends EditorInspectorPlugin

func _can_handle(object):
	return object is Attack

func _parse_begin(object):
	if object is Attack:
		var timeline_editor = preload("res://addons/attack_timeline_editor/attack_timeline_editor.tscn").instantiate()
		timeline_editor.set_attack(object)
		add_custom_control(timeline_editor)
		print('h!')
		return true
	return false
