extends Node

onready var nav : Navigation2D = $Navigation2D
onready var character : Node = $Character

func _input(event : InputEvent) -> void :
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	
	var path := nav.get_simple_path(character.global_position, event.global_position)
	character.path = path
