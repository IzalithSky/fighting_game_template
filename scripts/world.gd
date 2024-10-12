extends Node2D


@export var time_scale: float = 1.0
@export var player1_scene: PackedScene
@export var player2_scene: PackedScene
@export var fsm1_scene: PackedScene
@export var fsm2_scene: PackedScene
@export var player1_respawn_pos: Vector2 = Vector2(100, 320)
@export var player2_respawn_pos: Vector2 = Vector2(500, 320)
@export var pause_menu_scene: PackedScene = preload("res://scenes/pause_scene.tscn")

@onready var hpbar1 = $hpbar1
@onready var hpbar2 = $hpbar2
@onready var score = $score
@onready var label_distance = $LabelDistance
@onready var frame_data_bar = $framedatabar

var player1: Character
var player2: Character
var fsm1: CharacterStateMachine
var fsm2: CharacterStateMachine
var score_p1 = 0
var score_p2 = 0
var pause_menu: Control

func _ready() -> void:
	Engine.time_scale = time_scale
	
	spawn_players()
	reset_players()
	
	hpbar1.init_hp(player1.max_hp)
	hpbar2.init_hp(player2.max_hp)
	score.text = "0 : 0"


func spawn_players() -> void:
	fsm1 = fsm1_scene.instantiate()
	fsm2 = fsm2_scene.instantiate()

	add_child(fsm1)
	add_child(fsm2)

	player1 = player1_scene.instantiate()
	player2 = player2_scene.instantiate()
	
	player1.fsm = fsm1
	player2.fsm = fsm2	
	player1.opponent = player2
	player2.opponent = player1
	player1.input_prefix = "p1_"
	player2.input_prefix = "p2_"
	player1.frame_data_bar = frame_data_bar
	player2.frame_data_bar = frame_data_bar
	
	player1.damaged.connect(on_player_1_damaged)
	player2.damaged.connect(on_player_2_damaged)
	player1.died.connect(on_player_1_died)
	player2.died.connect(on_player_2_died)
	
	
	fsm1.set_character(player1)
	fsm2.set_character(player2)

	add_child(player1)
	add_child(player2)


func on_player_1_damaged(amount: Variant) -> void:
	hpbar1.hp = player1.current_hp


func on_player_2_damaged(amount: Variant) -> void:
	hpbar2.hp = player2.current_hp


func on_player_1_died() -> void:
	score_p2 += 1
	update_score()
	reset_players()


func on_player_2_died() -> void:
	score_p1 += 1
	update_score()
	reset_players()


func update_score() -> void:
	score.text = str(score_p1) + " : " + str(score_p2)


func reset_players() -> void:
	player1.reset(player1_respawn_pos)
	player2.reset(player2_respawn_pos)
	
	hpbar1.hp = player1.max_hp
	hpbar2.hp = player2.max_hp


func _physics_process(delta: float) -> void:
	var distance = abs(player1.position.x - player2.position.x)
	label_distance.text = str(round(distance))

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	if get_tree().paused:
		get_tree().paused = false
		if pause_menu:
			pause_menu.queue_free()
			pause_menu = null
	else:
		get_tree().paused = true
		pause_menu = pause_menu_scene.instantiate()
		get_tree().get_root().add_child(pause_menu)
		pause_menu.grab_focus()
