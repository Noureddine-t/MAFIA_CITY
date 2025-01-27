extends Control
#@onready var optionsMenu = preload("res://options_menu.tscn")
@onready var resume_button = $PanelContainer/VBoxContainer/Resume
@onready var restart_button = $PanelContainer/VBoxContainer/Restart
@onready var change_Character_button = $PanelContainer/VBoxContainer/ChangeCharacter
@onready var options_button = $PanelContainer/VBoxContainer/Options
@onready var quit_button = $PanelContainer/VBoxContainer/Quit

func _ready():
	$AnimationPlayer.play("RESET")
	resume_button.grab_focus()
	
func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()

func _process(delta):
	testEsc()
	
func _on_resume_pressed():
	resume()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_change_character_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/scenes/choose_character.tscn")
	
	# TODO
#func _on_options_pressed():
	#resume()
	#get_tree().change_scene_to_file("res://menu/menu.tscn")
	
func _on_quit_pressed():
	get_tree().quit()
