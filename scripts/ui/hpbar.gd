# hpbar.gd
extends ProgressBar


@onready var timer = $Timer
@onready var dmgbar = $dmgbar

var hp = 0 : set = set_hp


func set_hp(new_hp):
	var prev_hp = hp
	hp = min(max_value, new_hp)
	value = hp
	
	if hp < prev_hp:
		timer.start()
	else:
		dmgbar.value = hp


func init_hp(_hp):
	hp = _hp
	max_value = hp
	value = hp
	dmgbar.max_value = hp
	dmgbar.value = hp


func _on_timer_timeout() -> void:
	dmgbar.value = hp
