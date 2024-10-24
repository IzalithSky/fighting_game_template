# timeline_editor.gd
extends Control


@export var box_scene: PackedScene

@onready var timeline_area = $Panel/ScrollContainer/TimelineArea

const BOX_HEIGHT = 30
const TIME_SCALE = 50  # Pixels per second

var current_attack: Attack

var boxes = []


func _ready():
	# Initialize if needed
	pass


func set_attack(attack: Attack):
	current_attack = attack
	refresh_timeline()


func refresh_timeline():
	# Clear existing boxes
	for box in boxes:
		box.queue_free()
	boxes.clear()
	
	if not current_attack:
		return
	
	# Add Move boxes
	for move in current_attack.moves:
		add_box(move, "Move")
	
	# Add Hitbox boxes
	for hitbox in current_attack.hitboxes:
		add_box(hitbox, "Hitbox")
	
	# Optionally, add background grid or markers
	draw_grid()


func add_box(data_instance, box_type: String):
	var box = box_scene.instantiate()
	box.set_data(data_instance, box_type, TIME_SCALE)
	timeline_area.add_child(box)
	boxes.append(box)


func draw_grid():
	# Optional: Draw grid lines or time markers
	var grid = ColorRect.new()
	grid.color = Color(0.9, 0.9, 0.9, 0.3)
	grid.rect_size = Vector2(timeline_area.rect_size.x, timeline_area.rect_size.y)
	timeline_area.add_child(grid)
	grid.move_to_back()
