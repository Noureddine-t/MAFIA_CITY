class_name Hero_3 extends CharacterBody2D



var cardinal_direction: Vector2 = Vector2.DOWN
var direction: Vector2 = Vector2.ZERO
var move_speed: float = 220.0  
var dash_speed: float = 450.0  


var is_dashing: bool = false
var is_attacking: bool = false
var is_dead : bool = false

var state: String = "idle"
var last_horizontal_direction: Vector2 = Vector2.RIGHT  # Par défaut, le personnage fait face à droite
var combo_attack_count: int = 0  # Nouveau : compteur pour le combo d'attaque
var combo_timer: float = 0.0     # Nouveau : timer pour le combo
var max_combo_delay: float = 1.0  # Délai maximal pour enchaîner le combo
# Variables pour la santé
var health: int = 100  # Santé du héros
var attack_range: float = 50.0  # Distance à laquelle l'ennemi peut attaquer
var attack_damage: int = 10  # Dégâts de l'attaque

# Temps entre deux appuis consécutifs pour détecter un dash
var double_tap_time: float = 0.3
var last_tap_time_left: float = 0.0
var last_tap_time_right: float = 0.0
var hit_enemies = [] # Liste pour stocker les ennemis déjà touchés dans l'attaque



@onready var attack_area: Area2D = $ZoneAttack  # Zone d'attaque
@onready var attack_shape: CollisionShape2D = $ZoneAttack/handcollision  # Forme de collision de la zone d'attaque
@onready var attack_origin : Marker2D = $ZoneAttack/handcollision/attack_origin
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthbar = $CanvasLayer/BigHealthbar

func _ready() -> void:
	#sprite.scale *= 2  # Agrandir légèrement le sprite
	animation_player.play("idle")
	healthbar.init_health(health)
	


# Called every frame
func _process(_delta: float) -> void:
	if is_dead:
		return  
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")

	# Gestion du dash
	detect_double_tap(_delta)

	# Si Hero_3 est en train de tirer ou d'attaquer, il ne peut pas bouger
	if is_attacking:
		return

	# Mémoriser la direction horizontale
	if direction.x != 0:
		last_horizontal_direction = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT

	# Mettre à jour la direction et l'état du joueur
	if setDirection() or setState():
		UpdateAnimation()



	# Gérer l'input pour l'attaque
	if Input.is_action_just_pressed("attack"):
		attack()
 # Réduire le timer de combo si nécessaire
	if combo_timer > 0:
		combo_timer -= _delta
	else:
		combo_attack_count = 0  # Réinitialiser le combo si le temps est écoulé
		
func _physics_process(delta: float) -> void:
	if is_attacking:
		return

	# Appliquer la vitesse normale ou de dash
	var current_speed = dash_speed if is_dashing else move_speed
	velocity = direction * current_speed
	move_and_slide()

func setDirection() -> bool:
	
	var new_dir: Vector2 = cardinal_direction

	if direction == Vector2.ZERO:
		return false

	if direction.y == 0:
		if direction.x < 0:
			new_dir = Vector2.LEFT
		else:
			new_dir = Vector2.RIGHT
		if new_dir == Vector2.LEFT :
			sprite.scale.x = -abs(sprite.scale.x) 
			attack_area.scale.x = -1  # Déplace le Marker2D à gauche
			#attack_area.position.x = 10 #ajustement
		else :
			sprite.scale.x = abs(sprite.scale.x)
			attack_area.scale.x = 1 
			#attack_area.position.x = -1 #ajustement
			
		
		

	elif direction.x == 0:
		if direction.y < 0:
			new_dir = Vector2.UP
		else:
			new_dir = Vector2.DOWN

	if new_dir == cardinal_direction:
		return false

	cardinal_direction = new_dir
	return true

func setState() -> bool:
	var new_state: String
	if is_attacking:
		new_state = "attack_%d" % combo_attack_count  # Affiche attack_1, attack_2, ou attack_3
	elif is_dashing:
		new_state = "run"
	elif direction != Vector2.ZERO:
		new_state = "walk"
	else:
		new_state = "idle"

	if new_state == state:
		return false

	state = new_state
	return true

func UpdateAnimation() -> void:
	animation_player.play(state)

func detect_double_tap(delta: float) -> void:
	if Input.is_action_just_pressed("right"):
		if last_tap_time_right > 0 and last_tap_time_right < double_tap_time:
			is_dashing = true
		last_tap_time_right = double_tap_time

	elif Input.is_action_just_pressed("left"):
		if last_tap_time_left > 0 and last_tap_time_left < double_tap_time:
			is_dashing = true
		last_tap_time_left = double_tap_time

	if last_tap_time_right > 0:
		last_tap_time_right -= delta
	if last_tap_time_left > 0:
		last_tap_time_left -= delta

	if is_dashing and (Input.is_action_just_released("right") or Input.is_action_just_released("left")):
		is_dashing = false

# Fonction pour attaquer avec un combo
func attack() -> void:
	if is_dead:  # Si l'hero est déjà mort, ne pas recevoir de dégâts
		return
	if is_attacking and combo_attack_count >= 3:
		return  # Si le combo est terminé, ignorer d'autres attaques

	if combo_attack_count == 0 or combo_timer > 0:
		combo_attack_count += 1  # Incrémenter le nombre d'attaques dans le combo
		combo_timer = max_combo_delay  # Réinitialiser le délai du combo

	is_attacking = true
	hit_enemies.clear()  # Réinitialiser la liste des ennemis touchés pour cette attaque
	state = "attack_%d" % combo_attack_count  # Définit l'animation appropriée (attack_1, attack_2, attack_3)
	UpdateAnimation()

	if last_horizontal_direction == Vector2.LEFT:
		sprite.scale.x = -abs(sprite.scale.x)
		
	else:
		sprite.scale.x = abs(sprite.scale.x)
		

	# Délai entre chaque attaque pour permettre le combo
	await get_tree().create_timer(0.48).timeout

	# Infliger des dégâts à l'ennemi si en portée
	var enemies = get_tree().get_nodes_in_group("enemies")  # Assurez-vous que vos ennemis sont dans un groupe "enemies"

	if combo_attack_count >= 3:
		combo_attack_count = 0  # Réinitialiser après le troisième coup

	is_attacking = false
	setState()
	UpdateAnimation()
	

func take_damage(amount: int) -> void:
	if is_dead:  # Si l'hero est déjà mort, ne pas recevoir de dégâts
		return
	health -= amount  # Réduit la santé du héros
	print("Hero_3 took damage! Current health: " + str(health))
	animation_player.play("hurt")
	await get_tree().create_timer(0.25).timeout
	if direction == Vector2.ZERO:
		animation_player.play("idle")
	if health <= 0 and is_dead == false:
		die()  # Appeler la fonction die si la santé atteint 0
		
	healthbar.health = health
	

# Fonction pour gérer la mort du héros
func die() -> void:
	if is_dead:  # Si l'hero est déjà mort, ne pas exécuter la mort
		return
	is_dead = true
	print("Hero_3 is dead")
	animation_player.play("die")
	await get_tree().create_timer(1.0).timeout
	animation_player.play("dead")
	await get_tree().create_timer(5.0).timeout
	queue_free()  # Supprime l'objet du héros de la scène, ou tu peux gérer autrement la mort
	

func _on_zone_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):  # Vérifie si le corps en contact est un ennemi
		body.take_damage(attack_damage)  # Inflige des dégâts à l'ennemi
