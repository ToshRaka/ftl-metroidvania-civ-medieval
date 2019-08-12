extends Node

onready var nav : Navigation2D = $Navigation2D
onready var selection : Node = $Selection
onready var characters := [$Character1, $Character2]

var selected_characters = []

func _input(event : InputEvent) -> void :
	if event.is_action_pressed("right_click"):
		selection.clearArea()
		for character in selected_characters:
			if character.selected:
				var path := nav.get_simple_path(character.global_position, event.global_position)
				character.path = path

func resetSelected() -> void:
	selected_characters = []

func _on_SelectionArea_area_entered(area: Area2D) -> void:
	var character = area.get_parent()
	if character:
		character.selected = true
		selected_characters.append(character)
