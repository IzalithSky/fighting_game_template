extends Control


func _ready():
	$ResumeButton.grab_focus()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		on_resume_button_pressed()
		get_viewport().set_input_as_handled()


func on_resume_button_pressed() -> void:
	get_tree().paused = false
	queue_free()

func on_menu_button_pressed() -> void:
	get_tree().paused = false
	var world = get_tree().get_root().get_node("world")  # Replace "world" with the name of the node added as the game level
	if world:
		world.queue_free()
	queue_free()
	get_tree().change_scene_to_file("res://scenes/player_selection.tscn")
