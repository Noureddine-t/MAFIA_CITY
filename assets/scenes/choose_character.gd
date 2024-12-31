extends Node2D

# Liste des animations disponibles
var animations = ["hero_3", "hero", "hero_2"]
var current_index = 0

# Références aux nœuds nécessaires
@onready var animation_player = $SpriteController/AnimationPlayer
@onready var btn_previous = $SpriteController/prev
@onready var btn_next = $SpriteController/next
@onready var btn_start_game = $StartGame

func _ready():
	play_current_animation()


func _on_next_pressed():
	# Incrémenter l'index et vérifier les limites
	current_index += 1
	if current_index >= animations.size():
		current_index = 0
	play_current_animation()

func _on_prev_pressed() -> void:
	# Décrémenter l'index et vérifier les limites
	current_index -= 1
	if current_index < 0:
		current_index = animations.size() - 1
	play_current_animation()
		
func play_current_animation():
	# Récupérer le nom de l'animation actuelle et la jouer
	var current_animation = animations[current_index]
	animation_player.play(current_animation)
	
	# (Optionnel) Debug pour voir quelle animation est jouée
	print("Playing animation: ", current_animation)


func _on_start_game_pressed() -> void:
	var selected_animation = animations[current_index]
	var scene_path = ""

	match selected_animation:
		"hero":
			scene_path = "res://assets/scenes/playground_3.tscn"
		"hero_2":
			scene_path = "res://assets/scenes/playground_4.tscn"
		"hero_3":
			scene_path = "res://assets/scenes/playground_2.tscn"
	if scene_path != "":
		get_tree().change_scene_to_file(scene_path)
