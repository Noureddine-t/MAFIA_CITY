extends CanvasLayer


func _on_restart_pressed() -> void:
	click_sound()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://assets/scenes/ui/choose_character.tscn")


func _on_quit_pressed() -> void:
	click_sound()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func hover_sound():
	var hover = $hover
	hover.play()
	
func click_sound():
	var click = $click
	click.play()
	

func _on_restart_mouse_entered() -> void:
	hover_sound()


func _on_quit_mouse_entered() -> void:
	hover_sound()
