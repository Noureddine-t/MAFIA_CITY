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
var is_hurt : bool = false


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $ZoneAttack  # Zone d'attaque
@onready var attack_shape: CollisionShape2D = $ZoneAttack/CollisionShape2D  # Forme de collision de la zone d'attaque
@onready var attack_timer : Timer = $attackTimer
@onready var healthbar = $Healthbar


func _ready() -> void:
	#sprite.scale *= 2 
	animation_player.play("idle")
	add_to_group("enemies")  # Ajoutez l'ennemi au groupe "enemies"
	healthbar.init_health(health)
	

func _process(delta: float) -> void:
	if is_dead:
		return  
	if hero:
		
		if hero.is_dead or hero.health <= 0:
			stop_moving()  # Arrêter le mouvement de l'ennemi si le héros est mort
			return  # Ne pas exécuter le reste du code
			
		var distance_to_hero = position.distance_to(hero.position)
		## Si le héros est dans la portée d'attaque et que l'ennemi n'est pas en train d'attaquer
		if distance_to_hero <= attack_range:
			if not is_attacking:
				# Démarrer le Timer pour lancer l'attaque et marquer is_attacking
				is_attacking = true
				attack_timer.start()
				animation_player.play()
				stop_moving()  # Arrêter le mouvement pour l'attaque
		else:
			# Si le héros est hors de portée, suivre le héros
			if not is_attacking:
				follow_hero(delta)
func follow_hero(delta: float) -> void:
	if is_dead or is_hurt:
		return
	# Calculer la direction vers le héros
	var direction: Vector2 = (hero.position - position).normalized()

	# Déplacer l'ennemi vers le héros
	velocity = direction * move_speed
	move_and_slide()

	# Ajuster le sprite pour que l'ennemi fasse face au héros
	if direction.x < 0:
		sprite.scale.x = -abs(sprite.scale.x)# Faire face à gauche
		attack_area.scale.x = -1  # Déplace le Marker2D à gauche
		
	else:
		sprite.scale.x = abs(sprite.scale.x)  # Faire face à droite
		attack_area.scale.x = 1 
		
	animation_player.play("walk")
func attack() -> void:
	if is_dead or is_hurt:
		return  
	if hero:
		is_attacking = true  # Bloquer le mouvement pendant l'attaque
		velocity = Vector2.ZERO  # Stopper le mouvement
		
		var random_attack = randi_range(1, 3)
		animation_player.play("attack_%d" % random_attack)  # Jouer l'animation choisie aléatoirement
		await get_tree().create_timer(0.5).timeout 
		
		if hero.is_dead :
			is_attacking = false
		is_attacking = false  # Reprendre le comportement normal

func stop_moving() -> void:
	velocity = Vector2.ZERO  # Stopper le mouvement
	animation_player.play("idle")  # Revenir à l'animation idle
	
func take_damage(amount: int) -> void:
	if is_dead:  # Si l'ennemi est déjà mort, ne pas recevoir de dégâts
		return
	is_hurt = true
	health -= amount  # Réduit la santé de l'ennemi
	print("Enemy took damage! Current health: " + str(health))
	velocity = Vector2.ZERO
	animation_player.play("hurt")
	await get_tree().create_timer(0.25).timeout
	animation_player.play("idle")
	if health <= 0 and is_dead == false :
		die()  # Appelle la méthode die si la santé atteint 0
		
	healthbar.health = health
	is_hurt = false

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
	print("Body entered:", body.name)
		# Quand un corps (comme le héros) entre dans la zone de détection
	if body is CharacterBody2D and (body.name == "Hero_3" or body.name == "Hero" or body.name == "Hero2") :  # Vérifier que c'est le héros
		hero = body  # Sauvegarder la référence du héros


func _on_area_2d_body_exited(body: Node2D) -> void:
	if is_dead :
		return
	# Quand le héros quitte la zone de détection
	if body == hero:
		hero = null  # L'ennemi arrête de suivre le héros
		animation_player.play("idle")





func _on_zone_attack_body_entered(body: Node2D) -> void:
	if body == hero and not hero.is_dead:
		hero.take_damage(attack_damage)  # Inflige des dégâts au héros


func _on_timer_timeout() -> void:
	if is_dead :
		return
	print("temps écoulé")
	attack()
