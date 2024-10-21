class_name  Bullet_2 extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 1500 # Speed of the bullet

func _ready() -> void:
	# You can add any bullet-specific initialization here
	pass

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		velocity = direction * speed
		move_and_slide()
	
# Method to set the direction of the bullet
func set_direction(new_direction: Vector2) -> void:
	direction = new_direction
