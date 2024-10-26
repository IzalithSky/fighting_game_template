@tool
extends EditorPlugin

var attack_inspector_plugin

func _enter_tree():
	attack_inspector_plugin = preload("res://addons/attack_timeline_editor/attack_inspector_plugin.gd").new()
	add_inspector_plugin(attack_inspector_plugin)

func _exit_tree():
	remove_inspector_plugin(attack_inspector_plugin)
