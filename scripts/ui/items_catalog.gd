# itemss_catalog.gd
extends Control

signal character_selected(selected_character: Dictionary)

@export var slot_scene: PackedScene
@onready var grid = $GridContainer

var items: Array
var current_item: Dictionary

func set_library_data(title: String, items_array: Array, selected_item: Dictionary):
	$TitleLabel.text = title
	items = items_array
	current_item = selected_item

func _ready():
	populate_items_grid()

func populate_items_grid():
	var grid_width = grid.size.x
	var columns = grid.columns
	var slot_width = grid_width / columns
	
	for item_data in items:
		var slot = slot_scene.instantiate()
		slot.custom_minimum_size = Vector2(slot_width, slot_width)
		slot.assign_character(item_data)
		grid.add_child(slot)
		slot.connect("gui_input", Callable(self, "on_item_slot_click").bind(item_data))
		if (item_data["scene_path"] == current_item["scene_path"]):
			slot.grab_focus()
		
func on_item_slot_click(event: InputEvent, selected_item: Dictionary):
	if event is InputEventMouseButton and event.pressed:
		on_character_selected(selected_item)
			
	if event is InputEventKey and (event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept")):
		on_character_selected(selected_item)
	
func on_character_selected(selected_character: Dictionary):
	current_item = selected_character
	emit_signal("character_selected", selected_character)
	close_library()
	
func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		close_library()

func _on_back_button_pressed() -> void:
	close_library()

func close_library():
	queue_free() 
