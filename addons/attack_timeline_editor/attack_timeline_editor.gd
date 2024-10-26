@tool
extends VBoxContainer

var attack: Attack
var time_scale := 100.0 # Pixels per second
var timeline_length := 5.0 # Duration in seconds

func _ready():
	$Toolbar/AddMoveButton.connect("pressed", _on_AddMoveButton_pressed)
	$Toolbar/AddHitboxButton.connect("pressed", _on_AddHitboxButton_pressed)

func set_attack(attack_node):
	attack = attack_node
	update_timeline()

func update_timeline():
	$TimelineCanvas.clear_connections()
	for child in $TimelineCanvas.get_children():
		child.queue_free()

	var moves = []
	var hitboxes = []

	# Collect Moves and Hitboxes from the Attack node's children
	for child in attack.get_children():
		if child is Move:
			moves.append(child)
		elif child is Hitbox:
			hitboxes.append(child)

	for move in moves:
		var move_node = preload("res://addons/attack_timeline_editor/timeline_item.tscn").instantiate()
		move_node.init(move, "Move", time_scale)
		#$TimelineCanvas.add_child(move_node)
#
	#for hitbox in hitboxes:
		#var hitbox_node = preload("res://addons/attack_timeline_editor/timeline_item.tscn").instantiate()
		#hitbox_node.init(hitbox, "Hitbox", time_scale)
		#$TimelineCanvas.add_child(hitbox_node)

func _on_AddMoveButton_pressed():
	var move = Move.new()
	attack.add_child(move)
	move.owner = attack.get_owner() # Ensure the node is saved with the scene
	update_timeline()

func _on_AddHitboxButton_pressed():
	var hitbox = Hitbox.new()
	attack.add_child(hitbox)
	hitbox.owner = attack.get_owner()
	update_timeline()
