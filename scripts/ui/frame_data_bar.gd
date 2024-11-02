# frame_data_bar.gd
class_name FrameDataBar
extends Control

@export var block_count = 90
@export var clear_timeout = 240

var top_container: HBoxContainer
var bottom_container: HBoxContainer
var top_frame_counter: int = 0
var bottom_frame_counter: int = 0
var since_update: int = 0

func _ready():
	create_progress_bar()


func _physics_process(delta: float) -> void:
	if top_frame_counter > bottom_frame_counter:
		_update_bot_block_color(Color.WEB_GRAY)
	elif top_frame_counter < bottom_frame_counter:
		_update_top_block_color(Color.WEB_GRAY)
		
	since_update += 1
	if since_update > clear_timeout:
		clearblocks()
		since_update = 0
	

func create_progress_bar():
	var main_container = VBoxContainer.new()  # Root container for stacking HBoxContainers
	main_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(main_container)

	top_container = HBoxContainer.new()
	top_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_container.add_child(top_container)

	for i in range(block_count):
		var block = ColorRect.new()
		block.custom_minimum_size = Vector2(3, 10)
		block.color = Color.WEB_GRAY
		top_container.add_child(block)

	bottom_container = HBoxContainer.new()
	bottom_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_container.add_child(bottom_container)

	for i in range(block_count):
		var block = ColorRect.new()
		block.custom_minimum_size = Vector2(3, 10)
		block.color = Color.WEB_GRAY
		bottom_container.add_child(block)


func update_top_block_color(color: Color):
	since_update = 0
	_update_top_block_color(color)

func _update_top_block_color(color: Color):
	if top_frame_counter >= block_count: 
		clearblocks()
	
	var container: HBoxContainer = top_container

	if top_frame_counter >= 0 and top_frame_counter < container.get_child_count():
		var block = container.get_child(top_frame_counter) as ColorRect
		block.color = color
	else:
		print("Index out of bounds for progress bar blocks!")

	top_frame_counter += 1

func update_bot_block_color(color: Color):
	since_update = 0
	_update_bot_block_color(color)

func _update_bot_block_color(color: Color):
	if bottom_frame_counter >= block_count: 
		clearblocks()
	
	var container: HBoxContainer = bottom_container

	if bottom_frame_counter >= 0 and bottom_frame_counter < container.get_child_count():
		var block = container.get_child(bottom_frame_counter) as ColorRect
		block.color = color
	else:
		print("Index out of bounds for progress bar blocks!")

	bottom_frame_counter += 1


func clearblocks():
	top_frame_counter = 0
	bottom_frame_counter = 0	
	
	for i in range(top_container.get_child_count()):
		var block = top_container.get_child(i) as ColorRect
		block.color = Color.WEB_GRAY

	for i in range(bottom_container.get_child_count()):
		var block = bottom_container.get_child(i) as ColorRect
		block.color = Color.WEB_GRAY 
