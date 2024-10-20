class_name Naked_enemy_state_idle extends Naked_enemy_state

@export var anim_name : String = "idle"
@export_category("AI")
@export var state_duration_min : float = 0.5
@export var state_duration_max : float = 1.5
@export var after_idle_state: Naked_enemy_state

var _timer : float = 0.0
## What happens when we initialize this state?
func init() ->void:
	pass
	
## What happens when we enter this state?
func enter()->void:
	enemy.velocity = Vector2.ZERO
	_timer = randf_range( state_duration_min,state_duration_max)
	enemy.update_animation(anim_name)
	pass
	
## What happens when enemy exits this state?
func exit()->void:
	pass

## What happens during the _process update in this state?
func process (_delta:float )->Naked_enemy_state:
	_timer -= _delta
	if _timer <= 0:
		return after_idle_state
	return null
		
## What happens during the _physics_process update in this state?
func physics(_delta: float)->Naked_enemy_state:
	return null
