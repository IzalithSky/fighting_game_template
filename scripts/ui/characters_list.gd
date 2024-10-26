# characters_list.gd
extends Node

# A dictionary to store the character name and their scene path
var characters = [
	{"name": "Zidane", "scene_path": "res://scenes/characters/zidane.tscn", "preview": "res://sprites/characters/zidane/zidane_preview.png"},
	{"name": "Knight", "scene_path": "res://scenes/characters/knight.tscn", "preview": "res://sprites/characters/Knight_player/knight_preview.png"}
]

func get_all_characters() -> Array:
	return characters

# A dictionary to store the level name and scene path
var levels = [
	{"name": "The Dungeon", "scene_path": "res://scenes/levels/dungeon_background.tscn", "preview": "res://sprites/locations/dungeon/dungeon_preview.png"},
]

func get_all_levels() -> Array:
	return levels
