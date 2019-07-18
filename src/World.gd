extends Node

onready var nav : Navigation2D = $Navigation2D
onready var characters := [$Character1, $Character2]
onready var selector : ColorRect = $SelectCharacter

var large_selection : bool = false
var selected_characters = []

func _input(event : InputEvent) -> void :
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_RIGHT: # Set navigation target phase
				for character in characters:
					if character.selected:
						var path := nav.get_simple_path(character.global_position, event.global_position)
						character.path = path
						character.selected = false # Arbitrarily deselect character once they got a target
			elif event.button_index == BUTTON_LEFT: # Select phase
				var was_selected = false
				for character in characters:
					character.selected = character.CollisionMouse.hover
					was_selected = was_selected or character.selected
				
				# No character was selected, start a rectangular selection instead
				if not was_selected:
					large_selection = true
					selector.set_begin(event.global_position)
					selector.set_end(event.global_position)
					selector.visible = true
		
		else: # Mouse button released
			large_selection = false
			selector.visible = false

	elif event is InputEventMouseMotion:
		if large_selection:
			selector.set_end(event.global_position)
