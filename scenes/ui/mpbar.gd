# mpbar.gd
extends ProgressBar


var mp = 0 : set = set_mp


func set_mp(new_mp):
	value = min(max_value, new_mp)


func init_mp(_mp):
	value = mp
