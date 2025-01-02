extends CharacterBody2D


const bulletPath = preload('res://bulllet_2.tscn')  # Balle spécifique à enemie_2
# Variables
var cardinal_direction: Vector2 = Vector2.LEFT
var direction: Vector2 = Vector2.ZERO
var state: String = "idle"
var hero: CharacterBody2D = null  # Référence vers le héros à suivre
var move_speed: float = 150.0  # Vitesse de déplacement de l'ennemi
var attack_range: float = 50.0  # Distance à laquelle l'ennemi peut attaquer
var shoot_range : float = 900.0
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
	#sprite.scale *= 2 
	animation_player.play("idle")
	add_to_group("enemies")  # Ajoutez l'ennemi au groupe "enemies"
	healthbar.init_health(health)
	

func _process(delta: float) -> void:
	if is_dead:
		return  
	#if is_shooting or is_attacking or is_hurt :
	#		return
	if not is_walking and not is_shooting and not is_attacking and not is_hurt: 
		animation_player.play("idle")
	if is_walking and (velocity.length() == 0 or velocity != Vector2.ZERO):
		is_walking = false
		
	if hero:
		if hero.is_dead or hero.health <= 0:
			stop_moving()
			return
			
		if setState() or setDirectionTowardsHero(hero.global_position):
			UpdateAnimation()
		if hero.position.y - position.y == 0 : 
			is_aligned = true
		else : 
			is_aligned = false
			
		
		var distance_to_hero = position.distance_to(hero.position)

		# Priorité : Attaque ou Tir
		#if distance_to_hero <= attack_range:
		#	if not is_attacking and not is_walking:
		#		attack_timer.start()
		if distance_to_hero <= shoot_range and abs(hero.position.y - position.y) <= 10 :
			if not is_shooting:
				shoot_timer.start()
		elif distance_to_hero <= shoot_range and hero.position.y - position.y != 0 :
			if not is_attacking and not is_shooting:
				align_vertically_with_hero()
		if distance_to_hero <= shoot_range :
			if not is_shooting:
				shoot_timer.start()
		if hero.position.y == position.y:
			velocity.y = 0  # Arrêter si aligné
			is_walking = false
		#if not is_walking and not is_shooting:  # Mettre à jour l'animation si nécessaire
		#	animation_player.play("idle")
				
	else:
		stop_moving()

	
	
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

		if new_dir == Vector2.LEFT:
			sprite.scale.x = -abs(sprite.scale.x)
			attack_area.scale.x = -1  # Ajuste la zone d'attaque à gauche
		else:
			sprite.scale.x = abs(sprite.scale.x)
			attack_area.scale.x = 1   # Ajuste la zone d'attaque à droite

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
	elif velocity.length() > 0 or velocity != Vector2.ZERO: 
		new_state = "walk"
	else:
		new_state = "idle"

	if new_state == state:
		return false

	state = new_state
	return true
	
func UpdateAnimation() -> void:
	animation_player.play(state)
	
'''func follow_hero(delta: float) -> void:
	if not hero or  is_shooting or is_attacking or is_hurt or is_dead:
		return
	is_walking = true
	state = "walk"
	UpdateAnimation()
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

	is_walking = false
	setState()
	UpdateAnimation()
	'''
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
		is_attacking = false  # Reprendre le comportement normal
		setState()
		UpdateAnimation()
func shoot() -> void:
	if is_dead:
		return
	if hero :	
		if abs(hero.position.y - position.y) > 10:  # Tolérance de 10 pixels
			return
		is_shooting = true
		state = "shoot"
		UpdateAnimation()
		#wait get_tree().create_timer(1.0).timeout
		shoot_bullet()
		if last_horizontal_direction == Vector2.LEFT:
			sprite.scale.x = -abs(sprite.scale.x)
		else:
			sprite.scale.x = abs(sprite.scale.x)
	is_shooting = false
	setState()
	UpdateAnimation()

func shoot_bullet() -> void:
	var bullet = bulletPath.instantiate()
	get_parent().add_child(bullet)  # Ajoutez le projectile à la scène
	var bullet_offset_right = Vector2(30, 50)
	var bullet_offset_left = Vector2(-30, 50)
	if last_horizontal_direction == Vector2.RIGHT:
		bullet.global_position = global_position + bullet_offset_right
		bullet.set_direction(Vector2.RIGHT)
	else:
		bullet.global_position = global_position + bullet_offset_left
		bullet.set_direction(Vector2.LEFT)

	bullet.scale = Vector2(2.5, 2.5)  # Ajustement de l'échelle pour Hero2

func align_vertically_with_hero() -> void:
	if not hero or  is_shooting or is_attacking or is_hurt or is_dead:
		return
	if hero.position.y == position.y:
		velocity = Vector2.ZERO 
		is_walking = false
		return
	
	is_walking = true
	animation_player.play("walk")
	velocity.x = 0  # Pas de mouvement horizontal pendant l'alignement

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
	print("temps écoulé")
	attack()


func _on_shoot_timer_timeout() -> void:
	if is_dead :
		return
	print("temps shoot écoulé")
	shoot()
