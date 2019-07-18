extends Node

onready var nav : Navigation2D = $Navigation2D
onready var characters := [$Character1, $Character2]
onready var selecter : ColorRect = $SelectCharacter

var selected_characters = []

func _input(event : InputEvent) -> void :
	if not event is InputEventMouseButton or not event.pressed:
		return
	
	if event.button_index == BUTTON_RIGHT: # Set navigation target phase
		for character in characters:
			if character.selected:
				var path := nav.get_simple_path(character.global_position, event.global_position)
				character.path = path
				character.selected = false # Arbitrarily deselect character once they got a target
	elif event.button_index == BUTTON_LEFT: # Select phase
		for character in characters:
			character.selected = character.CollisionMouse.hover
