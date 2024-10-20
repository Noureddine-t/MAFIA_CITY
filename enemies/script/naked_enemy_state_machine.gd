class_name Naked_enemy_state_machine extends Node


var states : Array [ Naked_enemy_state]
var prev_state : Naked_enemy_state
var current_state: Naked_enemy_state

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode=Node.PROCESS_MODE_DISABLED
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	change_state(current_state.process(delta))
	pass
	
func _physics_process(delta):
	change_state(current_state.physics(delta))
	pass

func initialize (_enemy : Naked_enemy)->void:
	states= []
	for c in get_children():
		if c is Naked_enemy_state:
			states.append(c)
			
	for s in states:
		s.enemy= _enemy
		s.state_machine= self
		s.init()
	
	if states.size()>0:
		change_state(states[0])
		process_mode= Node.PROCESS_MODE_INHERIT
	pass
	

func change_state (new_state : Naked_enemy_state)->void:
	if new_state==null || new_state==current_state:
		return
		
	if current_state:
		current_state.exit()
		
	prev_state=current_state
	current_state=new_state
	current_state.enter()
