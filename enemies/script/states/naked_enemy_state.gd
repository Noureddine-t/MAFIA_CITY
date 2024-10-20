class_name Naked_enemy_state extends Node


## Stores a reference to the enemy that this state belings to
var enemy : Naked_enemy
var state_machine : Naked_enemy_state_machine

## What happens when we initialize this state?
func init() ->void:
	pass
	
## What happens when we enter this state?
func enter()->void:
	pass
	
## What happens when enemy exits this state?
func exit()->void:
	pass

## What happens during the _process update in this state?
func process (_delta:float )->Naked_enemy_state:
	return null
	
## What happens during the _physics_process update in this state?
func physics(_delta: float)->Naked_enemy_state:
	return null
