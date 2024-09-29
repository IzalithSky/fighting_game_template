extends Node2D

@onready var player1 = $player1
@onready var player2 = $player2

@onready var hpbar1 = $hpbar1
@onready var hpbar2 = $hpbar2

@onready var score = $score

var score_p1 = 0
var score_p2 = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hpbar1.init_hp(player1.max_hp)
	hpbar2.init_hp(player2.max_hp)
	score.text = "0 : 0"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Update player 1's HP bar when damaged
func _on_player_1_damaged(amount: Variant) -> void:
	hpbar1.hp = player1.current_hp

# Update player 2's HP bar when damaged
func _on_player_2_damaged(amount: Variant) -> void:
	hpbar2.hp = player2.current_hp

# Handle player 1's death
func _on_player_1_died() -> void:
	# Player 2 scores a point
	score_p2 += 1
	_update_score()

	# Reset positions and health
	_reset_players()

# Handle player 2's death
func _on_player_2_died() -> void:
	# Player 1 scores a point
	score_p1 += 1
	_update_score()

	# Reset positions and health
	_reset_players()

# Update the score display
func _update_score() -> void:
	score.text = str(score_p1) + " : " + str(score_p2)

# Reset players' health and positions
func _reset_players() -> void:
	# Reset health
	player1.current_hp = player1.max_hp
	player2.current_hp = player2.max_hp

	# Update HP bars
	hpbar1.hp = player1.max_hp
	hpbar2.hp = player2.max_hp

	# Reset positions (you can adjust these positions)
	player1.position = Vector2(100, 500)  # Example position
	player2.position = Vector2(700, 500)  # Example position

	# Reset player states (optional if needed)
	player1.velocity = Vector2.ZERO
	player2.velocity = Vector2.ZERO

	# Optionally stop any ongoing attacks or animations
	player1.is_attacking = false
	player2.is_attacking = false
	player1.anim.play("idle")
	player2.anim.play("idle")
