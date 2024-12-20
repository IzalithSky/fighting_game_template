# world.gd
class_name World
extends Node2D


@export var time_scale: float = 1.0
@export var background_scene: PackedScene
@export var pause_menu_scene: PackedScene
@export var player1_scene: PackedScene
@export var player2_scene: PackedScene
@export var fsm1_scene: PackedScene
@export var fsm2_scene: PackedScene
@export var player1_respawn_pos: Vector2 = Vector2(224, 400)
@export var player2_respawn_pos: Vector2 = Vector2(416, 400)
@export var post_round_delay: float = 3
@export var round_time_limit: float = 60

@onready var hpbar1 = $hpbar1
@onready var hpbar2 = $hpbar2
@onready var mpbar1 = $mpbar1
@onready var mpbar2 = $mpbar2
@onready var score = $score
@onready var label_distance = $DebugLabelsControl/LabelDistance
@onready var label_fps = $DebugLabelsControl/LabelFPS
@onready var label_pps = $DebugLabelsControl/LabelPPS
@onready var frame_data_bar = $framedatabar
@onready var touch_controls = $MobileControl/TouchControls
@onready var label_os = $DebugLabelsControl/LabelOS
@onready var countdown_label = $CountdownLabel
@onready var round_time_label = $LabelRoundTime

@onready var player_1_name_label = $player1label
@onready var player_2_name_label = $player2label

var player1: Character
var player2: Character
var fsm1: CharacterStateMachine
var fsm2: CharacterStateMachine
var player1name: String = ""
var player2name: String = ""
var score_p1 = 0
var score_p2 = 0
var pause_menu: Control
var countdown_timer: float = 0
var countdown_stage: int = 0
var is_countdown_active: bool = false
var post_round_timer: float = 2.0
var in_post_round_phase: bool = false
var round_timer: float = round_time_limit
var wins_required: int = 3
var current_round: int = 1


func _ready() -> void:
	Engine.time_scale = time_scale
	set_background()
	spawn_players()
	reset_players()
	hpbar1.init_hp(player1.max_hp)
	hpbar2.init_hp(player2.max_hp)
	mpbar1.init_mp(player1.current_mp)
	mpbar2.init_mp(player2.current_mp)
	score.text = "0 : 0"
	player_1_name_label.text = player1name
	player_2_name_label.text = player2name
	label_os.text = OS.get_name()
	var is_mobile = ConfigHandler.load_settings("video").mobile_controls or OS.get_name() == "Android" or OS.get_name() == "iOS"
	if is_mobile:
		touch_controls.visible = true
		touch_controls.set_process(true)
	else:
		touch_controls.visible = false
		touch_controls.set_process(false)
	start_round_with_countdown()


func _process(delta: float) -> void:
	label_fps.text = str(Engine.get_frames_per_second()) + " FPS"
	label_pps.text = str(Engine.physics_ticks_per_second) + " PPS"


func set_background():
	var background = background_scene.instantiate()
	add_child(background)
	move_child(background, 0)


func spawn_players() -> void:
	fsm1 = fsm1_scene.instantiate()
	fsm2 = fsm2_scene.instantiate()
	add_child(fsm1)
	add_child(fsm2)
	fsm1.priority_action.connect(on_player1_priority)
	fsm2.priority_action.connect(on_player2_priority)
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
	player1.mpchanged.connect(on_player_1_mpchanged)
	player2.mpchanged.connect(on_player_2_mpchanged)
	player1.kod.connect(on_player_1_kod)
	player2.kod.connect(on_player_2_kod)
	fsm1.set_character(player1)
	fsm2.set_character(player2)
	add_child(player1)
	add_child(player2)


func on_player1_priority() -> void:
	player1.z_index = 1
	player2.z_index = 0


func on_player2_priority() -> void:
	player1.z_index = 0
	player2.z_index = 1


func on_player_1_damaged(amount: Variant) -> void:
	hpbar1.hp = player1.current_hp


func on_player_2_damaged(amount: Variant) -> void:
	hpbar2.hp = player2.current_hp


func on_player_1_mpchanged(amount: Variant) -> void:
	mpbar1.mp = amount


func on_player_2_mpchanged(amount: Variant) -> void:
	mpbar2.mp = amount


func on_player_1_kod() -> void:
	score_p2 += 1
	update_score()
	end_round()


func on_player_2_kod() -> void:
	score_p1 += 1
	update_score()
	end_round()


func update_score() -> void:
	score.text = str(score_p1) + " : " + str(score_p2)


func reset_players() -> void:
	player1.reset(player1_respawn_pos)
	player2.reset(player2_respawn_pos)
	fsm1.start_intro()
	fsm2.start_intro()
	hpbar1.hp = player1.current_hp
	hpbar2.hp = player2.current_hp
	mpbar1.mp = player1.current_mp
	mpbar2.mp = player2.current_mp
	round_timer = round_time_limit  # Reset the round timer


func start_round_with_countdown() -> void:
	countdown_timer = 1.0
	countdown_stage = 4
	is_countdown_active = true
	countdown_label.visible = true
	update_countdown_label()


func start_post_round_phase() -> void:
	if score_p1 == wins_required or score_p2 == wins_required:
		show_winner()
	else: 
		countdown_label.visible = false
	in_post_round_phase = true
	post_round_timer = post_round_delay


func start_next_round() -> void:
	reset_players()
	start_round_with_countdown()


func show_winner():
	if score_p1 > score_p2:
		countdown_label.text = player1name + " Wins!"
	elif score_p1 < score_p2:
		countdown_label.text = player2name + " Wins!"
	else: 
		countdown_label.text = "Draw!"
	countdown_label.visible = true


func update_countdown_label() -> void:
	match countdown_stage:
		4: 
			if wins_required == 1:
				countdown_label.text = "One Chance"
			elif score_p1 == (wins_required - 1) and score_p2 == (wins_required - 1):
				countdown_label.text = "Final Round"
			else: 
				countdown_label.text = "Round " + str(current_round)
		3:
			countdown_label.text = "3"
		2:
			countdown_label.text = "2"
		1:
			countdown_label.text = "1"
		0:
			countdown_label.text = "Fight!"


func end_round():
	current_round += 1
	fsm1.end_round()
	fsm2.end_round()
	start_post_round_phase()


func end_round_due_to_timeout() -> void:
	if player1.current_hp > player2.current_hp:
		score_p1 += 1
	elif player2.current_hp > player1.current_hp:
		score_p2 += 1
	else:
		score_p1 += 1
		score_p2 += 1
	update_score()
	end_round()


func _physics_process(delta: float) -> void:
	if is_countdown_active:
		countdown_timer -= delta
		if countdown_timer <= 0:
			countdown_stage -= 1
			if countdown_stage < 0:
				is_countdown_active = false
				countdown_label.visible = false
				fsm1.start_round()
				fsm2.start_round()
			else:
				countdown_timer = 1.0
				update_countdown_label()
	
	if in_post_round_phase:
		post_round_timer -= delta
		if post_round_timer <= 0:
			in_post_round_phase = false
			if score_p1 == wins_required or score_p2 == wins_required:
				to_main_menu()
			else:
				start_next_round()

	if !is_countdown_active and !in_post_round_phase:
		round_timer -= delta
		round_time_label.text = str(int(round_timer))  # Update displayed round time
		if round_timer <= 0:
			end_round_due_to_timeout()

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


func to_main_menu():
	var world = get_tree().get_root().get_node("world")  # Replace "world" with the name of the node added as the game level
	if world:
		world.queue_free()
	queue_free()
	get_tree().change_scene_to_file("res://scenes/ui/player_selection.tscn")
