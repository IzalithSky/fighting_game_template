# world.gd
extends Node2D


@export var time_scale: float = 1.0

@onready var player1 = $player1
@onready var player2 = $player2

@onready var hpbar1 = $hpbar1
@onready var hpbar2 = $hpbar2

@onready var score = $score

@onready var label_distance = $LabelDistance

var score_p1 = 0
var score_p2 = 0


func _ready() -> void:
	Engine.time_scale = time_scale
	
	_reset_players()
	
	hpbar1.init_hp(player1.max_hp)
	hpbar2.init_hp(player2.max_hp)
	score.text = "0 : 0"


func _on_player_1_damaged(amount: Variant) -> void:
	hpbar1.hp = player1.current_hp


func _on_player_2_damaged(amount: Variant) -> void:
	hpbar2.hp = player2.current_hp


func _on_player_1_died() -> void:
	score_p2 += 1
	_update_score()
	_reset_players()


func _on_player_2_died() -> void:
	score_p1 += 1
	_update_score()
	_reset_players()


func _update_score() -> void:
	score.text = str(score_p1) + " : " + str(score_p2)


func _reset_players() -> void:
	player1.reset(Vector2(100, 320))
	player2.reset(Vector2(500, 320))
	
	hpbar1.hp = player1.max_hp
	hpbar2.hp = player2.max_hp


func _physics_process(delta: float) -> void:
	var distance = abs(player1.position.x - player2.position.x)
	label_distance.text = str(round(distance))
