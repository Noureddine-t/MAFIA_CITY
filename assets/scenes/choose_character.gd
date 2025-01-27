extends Node2D

# Liste des animations disponibles
var animations = ["hero_3", "hero", "hero_2", "police_1", "police_2", "police_3"]
var current_index = 0

# Références aux nœuds nécessaires
@onready var animation_player = $SpriteController/AnimationPlayer
@onready var btn_previous = $SpriteController/prev
@onready var btn_next = $SpriteController/next
@onready var btn_start_game = $StartGame
@onready var transition_layer = $TransitionLayer/ColorRect
@onready var transition_anim = $TransitionLayer/AnimationPlayer

func _ready():
	play_current_animation()
	btn_start_game.grab_focus()


func _on_next_pressed():
	var switch_sound = $ChangeCharacter # Play sound on click
	switch_sound.play()
	# Incrémenter l'index et vérifier les limites
	current_index += 1
	if current_index >= animations.size():
		current_index = 0
	play_current_animation()

func _on_prev_pressed() -> void:
	var switch_sound = $ChangeCharacter # Play sound on click
	switch_sound.play()
	# Décrémenter l'index et vérifier les limites
	current_index -= 1
	if current_index < 0:
		current_index = animations.size() - 1
	play_current_animation()

# Cas d'utilisation d'une manette
func _input(event):
	if event.is_action_pressed("right"):
		_on_next_pressed()
	elif event.is_action_pressed("left"):
		_on_prev_pressed()
		
func play_current_animation():
	# Récupérer le nom de l'animation actuelle et la jouer
	var current_animation = animations[current_index]
	animation_player.play(current_animation)
	
	# (Optionnel) Debug pour voir quelle animation est jouée
	print("Playing animation: ", current_animation)


func _on_start_game_pressed() -> void:
	var selected_animation = animations[current_index]
	var scene_path = ""
	var start_sound = $Click # Play sound on click
	start_sound.play()
	match selected_animation:
		"hero":
			scene_path = "res://assets/scenes/playground_3.tscn"
		"hero_2":
			scene_path = "res://assets/scenes/playground_4.tscn"
		"hero_3":
			scene_path = "res://assets/scenes/playground_2.tscn"
		"police_1":
			scene_path = "res://assets/scenes/playground_7.tscn"
		"police_2":
			scene_path = "res://assets/scenes/playground_5.tscn"
		"police_3":
			scene_path = "res://assets/scenes/playground_6.tscn"
	if scene_path != "":
		# Lancer la transition
		transition_anim.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file(scene_path)


func _on_start_game_mouse_entered() -> void:
	var hover_sound = $Hover # Hover button sound effect
	hover_sound.play()
