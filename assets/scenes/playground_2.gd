extends Node2D

# Références aux nœuds nécessaires
@onready var transition_layer = $TransitionLayer/ColorRect
@onready var transition_anim = $TransitionLayer/AnimationPlayer

func _ready():
	print("Playground_2 scene loaded")
	transition_anim.play("fade_out")


	
   
