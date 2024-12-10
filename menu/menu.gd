extends Control

@onready var start_button = $MarginContainer/VBoxContainer/Startbtn as Button
@onready var options_button = $MarginContainer/VBoxContainer/optionbtn as Button
@onready var exit_button = $MarginContainer/VBoxContainer/quitbtn as Button
@onready var options_menu = $Options_Menu as OptionMenu
@onready var margin_container = $MarginContainer as MarginContainer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle()
	
func toggle():
	visible = !visible
	get_tree().paused = visible

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.grab_focus()
	options_menu.exit_option_menu.connect(_on_exit_option_menu)

func _on_startbtn_pressed() -> void:
	toggle()
	get_tree().change_scene_to_file("res://playground.tscn")

func _on_optionbtn_pressed() -> void:
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true
	
func _on_quitbtn_pressed() -> void:
	get_tree().quit()

func _on_exit_option_menu() -> void:
	margin_container.visible = true
	options_menu.visible = false

	
	
