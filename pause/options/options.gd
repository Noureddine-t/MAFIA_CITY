extends Control

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0,value/5)


func _on_mute_toggled(toggled_on: bool) -> void:
		AudioServer.set_bus_volume_db(0,toggled_on)



func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600,900))
		2:
			DisplayServer.window_set_size(Vector2i(1280,720))


func _on_back_pressed() -> void:
	get_parent().show_pause_menu()
