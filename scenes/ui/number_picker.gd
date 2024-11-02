extends VBoxContainer

@export var values: Array[String] = [] 
@export var selected_index: int = 0 

signal value_changed(new_value: String)

@onready var value_label: Label = $ValueLabel

func _ready() -> void:
	update_display()

func update_display() -> void:
	if values.size() > 0:
		value_label.text = values[selected_index]

func set_selected_index(new_index: int) -> void:
	if values.size() == 0:
		return

	selected_index = (new_index + values.size()) % values.size()
	update_display()
	#emit_signal("value_changed", values[selected_index])

func on_button_up_pressed() -> void:
	set_selected_index(selected_index + 1)

func on_button_down_pressed() -> void:
	set_selected_index(selected_index - 1)

func get_selected_value_as_string() -> String:
	return values[selected_index] if selected_index < values.size() else ""

func get_selected_value_as_number() -> int:
	var value_str = get_selected_value_as_string()
	var numeric_part = ""
	for char in value_str:
		if char.is_digit():
			numeric_part += char
	return int(numeric_part) if numeric_part != "" else 0
