class_name Playergame extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var move_speed : float = 100.0
var state : String = "idle"



@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	velocity = direction * move_speed
	if setState() == true || setDirection() == true:
		UpdateAnimation()
	
	pass
	
func _physics_process(_delta) :
	move_and_slide()


func setDirection() -> bool :
	var new_dir : Vector2 = cardinal_direction
	if direction == Vector2.ZERO :
		return false
	
	if direction.y == 0 :
		if direction.x < 0 :
			new_dir =Vector2.LEFT
		else :
			new_dir =Vector2.RIGHT
	elif direction.x == 0 :
		if direction.y < 0 :
			new_dir = Vector2.UP
		else :
			new_dir = Vector2.DOWN
	
	if new_dir == cardinal_direction :
		return false
	
	cardinal_direction = new_dir
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	
		
	return true


func setState() -> bool :
	var new_state : String 
	if direction == Vector2.ZERO :
		new_state = "idle"  
	else : new_state = "walk"
	if new_state == state :
		return false
	state = new_state
	return true
	

func UpdateAnimation() -> void :
	animation_player.play(state + "_" + AnimDirection() )
	
	
	
func AnimDirection() -> String :
	if cardinal_direction == Vector2.DOWN : 
		return "down"
	elif cardinal_direction == Vector2.UP :
		return "up"
	else :
		return "side"
