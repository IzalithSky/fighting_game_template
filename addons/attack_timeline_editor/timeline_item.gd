@tool
extends GraphNode

var item
var item_type
var time_scale

func init(item_ref, item_type_str, scale):
	item = item_ref
	item_type = item_type_str
	time_scale = scale
	set_title(item_type)
	set_slot(0, false, 0, Color.TRANSPARENT, false, 0, Color.TRANSPARENT)
	set_resizable(true)
	set_draggable(true)
	update_visuals()
	connect("dragged", _on_dragged)
	connect("resize_request", _on_resize_request)
	print('h!')

func update_visuals():
	set_position(Vector2(item.time_start * time_scale, 0))
	set_size(Vector2(item.duration * time_scale, 50))
	set_title("%s (%.2fs)" % [item_type, item.duration])

func _on_dragged(from, to):
	var delta = to - from
	var new_time_start = item.time_start + delta.x / time_scale
	new_time_start = max(0, new_time_start)
	item.time_start = new_time_start
	update_visuals()

func _on_resize_request(new_size):
	var new_duration = new_size.x / time_scale
	new_duration = max(0.1, new_duration)
	item.duration = new_duration
	update_visuals()
