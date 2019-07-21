extends Node

onready var nav : Navigation2D = $Navigation2D
onready var characters := [$Character1, $Character2, $Character3, $Character4, $Character5, $Character6]
onready var selector : ColorRect = $SelectCharacter

var large_selection : bool = false
var select_anchor : Vector2 = Vector2()
var selected_characters = []

func tweak_rectangle(begin : Vector2, end : Vector2):
	if begin.x > end.x:
		var temp := begin.x
		begin.x = end.x
		end.x = temp
	
	if begin.y > end.y:
		var temp := begin.y
		begin.y = end.y
		end.y = temp
	
	return [begin, end]

func _input(event : InputEvent) -> void :
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_RIGHT: # Set navigation target phase
				for character in selected_characters:
					if character.selected: # Redundant / useless?
						var path := nav.get_simple_path(character.global_position, event.global_position)
						character.path = path
			elif event.button_index == BUTTON_LEFT: # Select phase
				var was_selected : bool = false
				selected_characters = []
				for character in characters:
					character.selected = character.CollisionMouse.hover
					if character.selected:
						selected_characters.append(character)
						was_selected = true
				
				# No character was selected, start a rectangular selection instead
				if not was_selected:
					large_selection = true
					selector.set_begin(event.global_position)
					selector.set_end(event.global_position)
					selector.visible = true
					select_anchor = event.global_position
		
		else: # Mouse button released
			if large_selection:
				selected_characters = []
				var rect : Rect2 = Rect2(selector.get_begin(), selector.get_end()-selector.get_begin())
				for character in characters:
					character.selected = rect.has_point(character.global_position)
					if character.selected:
						selected_characters.append(character)
			
			large_selection = false
			selector.visible = false

	elif event is InputEventMouseMotion:
		if large_selection:
			var temp = tweak_rectangle(select_anchor, event.global_position)
			var begin : Vector2 = temp[0]
			var end : Vector2 = temp[1]
			selector.set_begin(begin)
			selector.set_end(end)
