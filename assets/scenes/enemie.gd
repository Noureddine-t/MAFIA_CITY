extends CharacterBody2D

# Variables
var hero: CharacterBody2D = null  # Référence vers le héros à suivre
var move_speed: float = 150.0  # Vitesse de déplacement de l'ennemi
var attack_range: float = 50.0  # Distance à laquelle l'ennemi peut attaquer
var attack_damage: int = 10  # Dégâts de l'attaque
var is_attacking: bool = false  # Pour éviter de suivre et d'attaquer en même temps
var detection_radius: float = 300.0  # Distance à laquelle l'ennemi détecte le héros
var health: int = 50  # Santé de l'ennemi
var is_dead : bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	sprite.scale *= 2 
	animation_player.play("idle")
	add_to_group("enemies")  # Ajoutez l'ennemi au groupe "enemies"

func _process(delta: float) -> void:
	if is_dead:
		return  
	if hero:
		# Si l'ennemi n'est pas en train d'attaquer, il suit le héros
		if hero.is_dead or hero.health <= 0:
			stop_moving()  # Arrêter le mouvement de l'ennemi si le héros est mort
			return  # Ne pas exécuter le reste du code
		if not is_attacking:
			follow_hero(delta)

		# Si le héros est à portée d'attaque, lancer l'attaque
		if position.distance_to(hero.position) <= attack_range and not is_attacking and hero.is_dead == false:
			attack()

func follow_hero(delta: float) -> void:
	# Calculer la direction vers le héros
	var direction: Vector2 = (hero.position - position).normalized()

	# Déplacer l'ennemi vers le héros
	velocity = direction * move_speed
	move_and_slide()

	# Ajuster le sprite pour que l'ennemi fasse face au héros
	if direction.x < 0:
		sprite.scale.x = -abs(sprite.scale.x)# Faire face à gauche
	else:
		sprite.scale.x = abs(sprite.scale.x)  # Faire face à droite
	animation_player.play("walk")
func attack() -> void:
	is_attacking = true  # Bloquer le mouvement pendant l'attaque
	velocity = Vector2.ZERO  # Stopper le mouvement

	# Jouer l'animation d'attaque
	animation_player.play("attack_1")
	# Attendre que l'animation soit terminée (exemple avec 0.5 seconde)
	await get_tree().create_timer(0.5).timeout

	# Appliquer les dégâts au héros
	if position.distance_to(hero.position) <= attack_range and not hero.is_dead:
		hero.take_damage(attack_damage)  # Fonction dans le script du héros pour recevoir des dégâts
	if hero.is_dead :
		is_attacking = false
	is_attacking = false  # Reprendre le comportement normal

# Arrêter de bouger et revenir à l'animation "idle"
func stop_moving() -> void:
	velocity = Vector2.ZERO  # Stopper le mouvement
	animation_player.play("idle")  # Revenir à l'animation idle
	
func take_damage(amount: int) -> void:
	if is_dead:  # Si l'ennemi est déjà mort, ne pas recevoir de dégâts
		return
	health -= amount  # Réduit la santé de l'ennemi
	print("Enemy took damage! Current health: " + str(health))
	animation_player.play("hurt")
	await get_tree().create_timer(0.25).timeout
	if health <= 0 and is_dead == false :
		die()  # Appelle la méthode die si la santé atteint 0

func die() -> void:
	if is_dead:  # Si l'ennemi est déjà mort, ne pas exécuter la mort
		return
	is_dead = true
	print("Enemy is dead")
	animation_player.play("die")
	await get_tree().create_timer(1.0).timeout
	animation_player.play("dead")
	await get_tree().create_timer(5.0).timeout
	queue_free()  # Supprime l'ennemi de la scène

func _on_area_2d_body_entered(body: Node2D) -> void:
		# Quand un corps (comme le héros) entre dans la zone de détection
	if body is CharacterBody2D and body.name == "Hero_3":  # Vérifier que c'est le héros
		hero = body  # Sauvegarder la référence du héros


func _on_area_2d_body_exited(body: Node2D) -> void:
	# Quand le héros quitte la zone de détection
	if body == hero:
		hero = null  # L'ennemi arrête de suivre le héros
		animation_player.play("idle")
