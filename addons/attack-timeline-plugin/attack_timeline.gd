@tool
extends Control

@onready var main_control = $VBoxContainer/MainControl
@onready var no_selection = $VBoxContainer/NoAttackSelectedLabel
@onready var attack_title_label = $VBoxContainer/HBoxContainer/AttackTitleLabel

var selected_attack: Attack = null

func refresh_selection(selected_nodes: Array):
	if selected_nodes.size() > 0 and selected_nodes[0] is Attack:
		main_control.visible = true
		no_selection.visible = false
		selected_attack = selected_nodes[0]
		attack_title_label.text = selected_attack.name
		update_timeline()
	else:
		main_control.visible = false
		no_selection.visible = true
		attack_title_label.text = ""

func update_timeline():
	pass
