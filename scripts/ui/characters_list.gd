# characters_list.gd
extends Node

# A dictionary to store the character name and their scene path
var characters = [
	{"name": "Zidane", "scene_path": "res://scenes/characters/zidane.tscn"},
	{"name": "Knight", "scene_path": "res://scenes/characters/knight.tscn"}
]

# Function to get the list of all characters
func get_all_characters() -> Array:
	return characters
