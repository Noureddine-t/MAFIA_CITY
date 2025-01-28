extends Control
#@onready var optionsMenu = preload("res://options_menu.tscn")
@onready var resume_button = $PanelContainer/VBoxContainer/Resume
@onready var restart_button = $PanelContainer/VBoxContainer/Restart
@onready var change_Character_button = $PanelContainer/VBoxContainer/ChangeCharacter
@onready var setting_button = $PanelContainer/VBoxContainer/Settings
@onready var quit_button = $PanelContainer/VBoxContainer/Quit
@onready var options = $Options

func _ready():
	set_menu_active(false)
	$AnimationPlayer.play("RESET")
	
	
func resume():
	set_menu_active(false)
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	set_menu_active(true)
	resume_button.grab_focus()
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
	click_sound()
	resume()

func _on_restart_pressed() -> void:
	click_sound()
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_change_character_pressed() -> void:
	click_sound()
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/scenes/choose_character.tscn")
	
func show_pause_menu():
	$Options.hide()
	$PanelContainer.show()
	
func _on_settings_pressed():
	click_sound()
	$Options.show()
	$PanelContainer.hide()
	

func _on_quit_pressed():
	click_sound()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func hover_sound():
	var hover = $hover
	hover.play()
	
func click_sound():
	var click = $click
	click.play()
	
	
func _on_resume_mouse_entered() -> void:
	hover_sound()


func _on_restart_mouse_entered() -> void:
	hover_sound()


func _on_change_character_mouse_entered() -> void:
	hover_sound()


func _on_settings_mouse_entered() -> void:
	hover_sound()


func _on_quit_mouse_entered() -> void:
	hover_sound()
	
func set_menu_active(active: bool):
	$PanelContainer.visible = active
	for button in $PanelContainer/VBoxContainer.get_children():
		if button is Button:
			button.disabled = not active
