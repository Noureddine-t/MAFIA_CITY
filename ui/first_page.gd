extends Control

const next_scene = "res://assets/scenes/choose_character.tscn"

func _input(event):
	if event.is_pressed():
		_load_character_select_scene()

func _load_character_select_scene():
	var result = get_tree().change_scene_to_file(next_scene)
	if result != OK:
		print("Erreur lors du chargement de la scène :", result)
