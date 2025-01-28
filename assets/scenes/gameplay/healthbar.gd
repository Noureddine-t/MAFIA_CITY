extends ProgressBar


@onready var timer = $Timer
@onready var timer2 = $Timer2 #timer to hide the healthbar
@onready var damage_bar = $DamageBar

var health = 0 : set = _set_health

func  _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if health <= 0:
		queue_free()
		
	if health < prev_health:
		timer.start()
		timer2.start()
	else : 
		damage_bar.value = health
		
		

func  init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health
	hide_health_bar()
	
func show_health_bar():
	visible = true  # Rendre la barre visible

func hide_health_bar():
	visible = false  # Masquer la barre


func _on_timer_timeout() -> void:
	damage_bar.value = health


func _on_timer_2_timeout() -> void:
	hide_health_bar()
