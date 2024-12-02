class_name OptionMenu
extends Control

@onready var button = $MarginContainer/VBoxContainer/exitbtn as Button
# Called when the node enters the scene tree for the first time.


signal exit_option_menu


func _ready() -> void:
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exitbtn_pressed() -> void:
	exit_option_menu.emit()
	set_process(false)


func _on_exit_option_menu() -> void:
	pass # Replace with function body.
