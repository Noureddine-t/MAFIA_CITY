extends Node2D

@onready var transition_layer = $TransitionLayer/ColorRect
@onready var transition_anim = $TransitionLayer/AnimationPlayer

func _ready():
	print("Playground_4 scene loaded")
	transition_anim.play("fade_out")


	
