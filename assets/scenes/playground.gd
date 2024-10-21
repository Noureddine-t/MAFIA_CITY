extends Node2D

var pscene = load('res://assets/scenes/hero_2.tscn')

func onSwitchscene():
	get_tree().change_scene_to_packed(pscene)


func _process(delta: float) -> void:
	# Appuyer sur "Tab" pour changer de personnage
	if Input.is_action_just_pressed("switch_character"):
		onSwitchscene()
