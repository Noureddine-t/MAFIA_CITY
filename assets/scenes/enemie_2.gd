extends CharacterBody2D


const bulletPath = preload('res://bulllet_2.tscn')  # Balle spécifique à enemie_2
# Variables
var cardinal_direction: Vector2 = Vector2.LEFT
var direction: Vector2 = Vector2.ZERO
var state: String = "idle"
var hero: CharacterBody2D = null  # Référence vers le héros à suivre
var move_speed: float = 100.0  # Vitesse de déplacement de l'ennemi
var attack_range: float = 50.0  # Distance à laquelle l'ennemi peut attaquer

var attack_damage: int = 10  # Dégâts de l'attaque
var detection_radius: float = 300.0  # Distance à laquelle l'ennemi détecte le héros
var health: int = 50  # Santé de l'ennemi
var is_walking : bool = false 
var is_dead : bool = false 
var is_hurt : bool = false
var is_attacking: bool = false  # Pour éviter de suivre et d'attaquer en même temps
var is_shooting: bool = false
var last_horizontal_direction: Vector2 = Vector2.LEFT
var is_aligned : bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $ZoneAttack  # Zone d'attaque
@onready var attack_shape: CollisionShape2D = $ZoneAttack/CollisionShape2D  # Forme de collision de la zone d'attaque
@onready var attack_timer : Timer = $attackTimer
@onready var shoot_timer : Timer = $shootTimer
@onready var healthbar = $Healthbar


func _ready() -> void:
	animation_player.play(state)
	add_to_group("enemies")  # Ajoutez l'ennemi au groupe "enemies"
	healthbar.init_health(health)
	
func _process(delta: float) -> void:
	if is_dead or is_hurt:
		return  

	# Mettre à jour le dernier mouvement horizontal
	if direction.x != 0:
		last_horizontal_direction = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
		print("Updated last_horizontal_direction to: ", last_horizontal_direction)
		
	# Si un héros est détecté
	if hero:
		if hero.is_dead or hero.health <= 0:
			stop_moving()
			return
		
		# Calculer la distance au héros
		var distance_to_hero = position.distance_to(hero.position)
		
		# Priorité : attaque de mêlée si le héros est dans la portée d'attaque
		if distance_to_hero <= 50:
			if not is_attacking:
				print("Condition d'attaque de mêlée satisfaite : distance =", distance_to_hero)
				attack()
				#await get_tree().create_timer(1.5).timeout
				
			return  # Pas de tir si une attaque de mêlée est en cours

		# Tir immédiat si les conditions sont réunies
		if abs(hero.position.y - position.y) <= 10 :
			if not is_shooting:
				print("Condition de tir satisfaite : distance =", distance_to_hero)
				is_shooting = true  # Empêche de tirer à nouveau immédiatement
				shoot()
		else:
			is_shooting = false  # Réinitialiser si les conditions ne sont plus valides
		
		# Mise à jour de l'état et des animations
		var state_changed = setState()  # Mettre à jour l'état
		var direction_changed = setDirectionTowardsHero(hero.global_position)
		if state_changed or direction_changed:
			UpdateAnimation()
			
		# L'ennemi fait face au héros
		face_hero()

		# Arrêter les déplacements si aligné pour le tir
		if abs(hero.position.y - position.y) <= 10:
			is_walking = false
		else:
			align_vertically_with_hero() # S'aligne verticalement si nécessaire

	else:
		stop_moving()

			


	
func face_hero() -> void:
	# Vérifie la position du héros par rapport à l'ennemi
	if hero.global_position.x < global_position.x:
		# Le héros est à gauche
		sprite.scale.x = -abs(sprite.scale.x)  # Inverse pour faire face à gauche
		attack_area.scale.x = -1  # Ajuste la zone d'attaque à gauche
		last_horizontal_direction = Vector2.LEFT
	else:
		# Le héros est à droite
		sprite.scale.x = abs(sprite.scale.x)  # Normale pour faire face à droite
		attack_area.scale.x = 1  # Ajuste la zone d'attaque à droite
		last_horizontal_direction = Vector2.RIGHT




func setDirectionTowardsHero(hero_position: Vector2) -> bool:
	var new_dir: Vector2 = cardinal_direction

	# Calculer la direction vers le héros
	var direction_to_hero: Vector2 = (hero_position - global_position).normalized()

	if direction_to_hero == Vector2.ZERO:
		return false

	# Déterminer la direction principale (horizontale ou verticale dominante)
	if abs(direction_to_hero.x) > abs(direction_to_hero.y):
		if direction_to_hero.x < 0:
			new_dir = Vector2.LEFT
		else:
			new_dir = Vector2.RIGHT
	else:
		if direction_to_hero.y < 0:
			new_dir = Vector2.UP
		else:
			new_dir = Vector2.DOWN

	# Vérifier si la direction a changé
	if new_dir == cardinal_direction:
		return false

	cardinal_direction = new_dir
	return true

func setState() -> bool:
	var new_state: String

	if is_shooting:
		new_state = "shoot"
	elif is_attacking:
		new_state = "attack"
	elif is_hurt:
		new_state = "hurt"
	elif is_walking:
		new_state = "walk"
	else:
		new_state = "idle"

	if new_state == state:
		return false

	state = new_state
	return true
	
func UpdateAnimation() -> void:
	print("playing state : ", state)
	animation_player.play(state)
	
	
func attack() -> void:
	if is_dead:
		return  
	if hero:
		is_attacking = true 
		velocity = Vector2.ZERO  # Stopper le mouvement
		state = "attack"
		UpdateAnimation()
		
		if hero.is_dead :
			is_attacking = false
		await get_tree().create_timer(0.5).timeout
		is_attacking = false  # Reprendre le comportement normal
		setState()
		UpdateAnimation()
func shoot() -> void:
	if is_dead:
		return
	if hero :	
		#if abs(hero.position.y - position.y) > 10:  # Tolérance de 10 pixels
		#	return
		is_shooting = true
		state = "shoot"
		UpdateAnimation()
		await get_tree().create_timer(0.21).timeout
		shoot_bullet()
		face_hero()
		#if last_horizontal_direction == Vector2.LEFT:
		#	sprite.scale.x = -abs(sprite.scale.x)
		#else:
		#	sprite.scale.x = abs(sprite.scale.x)
	is_shooting = false
	setState()
	UpdateAnimation()

func shoot_bullet() -> void:
	var bullet = bulletPath.instantiate()
	get_parent().add_child(bullet)

	# Détermine la position et la direction
	var bullet_offset = Vector2(30, 50) if last_horizontal_direction == Vector2.RIGHT else Vector2(-30, 50)
	bullet.global_position = global_position + bullet_offset
	bullet.set_direction(last_horizontal_direction)

	bullet.scale = Vector2(2.5, 2.5)  # Taille spécifique pour l'ennemi


func align_vertically_with_hero() -> void:
	is_walking = true
	animation_player.play("walk")
	velocity.x = 0  # Pas de mouvement horizontal pendant l'alignement
	
	if not hero or  is_shooting or is_attacking or is_hurt or is_dead:
		return
	if hero.position.y == position.y:
		velocity = Vector2.ZERO 
		is_walking = false
		return
	
	

	if hero.position.y > position.y:
		velocity.y = move_speed
	elif hero.position.y < position.y:
		velocity.y = -move_speed
	
	move_and_slide()
	
		
func stop_moving() -> void:
	velocity = Vector2.ZERO  # Stopper le mouvement
	animation_player.play("idle")  # Revenir à l'animation idle
	
func take_damage(amount: int) -> void:
	if is_dead:  # Si l'ennemi est déjà mort, ne pas recevoir de dégâts
		return
	is_hurt = true
	health -= amount  # Réduit la santé de l'ennemi
	state= "hurt"
	UpdateAnimation()
	print("Enemy took damage! Current health: " + str(health))
	velocity = Vector2.ZERO
	animation_player.play("hurt")
	if health <= 0 and is_dead == false :
		die()  # Appelle la méthode die si la santé atteint 0
	else :
		await get_tree().create_timer(0.25).timeout
	
	healthbar.show_health_bar()
	healthbar.health = health
	
	is_hurt = false
	setState()
	UpdateAnimation()

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

func _on_attack_timer_timeout() -> void:
	if is_dead :
		return
	print("temps attack écoulé")
	attack()
