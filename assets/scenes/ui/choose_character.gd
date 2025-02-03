extends Node2D

# Liste des animations disponibles avec leurs noms
var characters = [
	{"name": "Iron Fist", "animation": "hero_3"},
	{"name": "Vinnie", "animation": "hero"},
	{"name": "Tony", "animation": "hero_2"},
	{"name": "Ellie", "animation": "police_1"},
	{"name": "Big Mike", "animation": "police_2"},
	{"name": "Old Dog", "animation": "police_3"}
]
var current_index = 0

# Références aux nœuds nécessaires
@onready var animation_player = $SpriteController/AnimationPlayer
@onready var btn_previous = $SpriteController/prev
@onready var btn_next = $SpriteController/next
@onready var btn_start_game = $StartGame
@onready var transition_layer = $TransitionLayer/ColorRect
@onready var transition_anim = $TransitionLayer/AnimationPlayer
@onready var character_name_label = $CharacterName # Label ou LineEdit pour afficher le nom

func _ready():
	play_current_character()
	btn_start_game.grab_focus()

func _on_next_pressed():
	var switch_sound = $ChangeCharacter # Play sound on click
	switch_sound.play()
	# Incrémenter l'index et vérifier les limites
	current_index += 1
	if current_index >= characters.size():
		current_index = 0
	play_current_character()

func _on_prev_pressed() -> void:
	var switch_sound = $ChangeCharacter # Play sound on click
	switch_sound.play()
	# Décrémenter l'index et vérifier les limites
	current_index -= 1
	if current_index < 0:
		current_index = characters.size() - 1
	play_current_character()

# Cas d'utilisation d'une manette
func _input(event):
	if event.is_action_pressed("right"):
		_on_next_pressed()
	elif event.is_action_pressed("left"):
		_on_prev_pressed()

func play_current_character():
	# Récupérer les données du personnage actuel et jouer l'animation
	var current_character = characters[current_index]
	animation_player.play(current_character["animation"])
	character_name_label.text = current_character["name"]

	# (Optionnel) Debug pour voir quelle animation est jouée
	print("Playing animation: ", current_character["animation"])

func _on_start_game_pressed() -> void:
	var selected_character = characters[current_index]
	var scene_path = ""
	var start_sound = $Click # Play sound on click
	start_sound.play()
	match selected_character["animation"]:
		"hero":
			scene_path = "res://assets/scenes/playgrounds/playground_3.tscn"
		"hero_2":
			scene_path = "res://assets/scenes/playgrounds/playground_4.tscn"
		"hero_3":
			scene_path = "res://assets/scenes/playgrounds/playground_2.tscn"
		"police_1":
			scene_path = "res://assets/scenes/playgrounds/playground_7.tscn"
		"police_2":
			scene_path = "res://assets/scenes/playgrounds/playground_5.tscn"
		"police_3":
			scene_path = "res://assets/scenes/playgrounds/playground_6.tscn"
	if scene_path != "":
		# Lancer la transition
		transition_anim.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file(scene_path)

func _on_start_game_mouse_entered() -> void:
	var hover_sound = $Hover # Hover button sound effect
	hover_sound.play()
