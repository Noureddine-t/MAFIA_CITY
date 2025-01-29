class_name  Bullet_2 extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 1500 # Speed of the bullet
var bullet_damage: int = 5

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


func _on_bullet_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") or body.is_in_group("heros"):  # Vérifie si le corps en contact est un ennemi
		body.take_damage(bullet_damage)  # Inflige des dégâts à l'ennemi
		queue_free()
