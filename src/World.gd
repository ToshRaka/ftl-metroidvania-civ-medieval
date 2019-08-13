extends Node

onready var nav : Navigation2D = $Navigation2D

const TeamMemberHUD := preload("res://Assets/TeamMemberHUD.tscn")

onready var selection : Node = $Selection
onready var characters := [$Character1, $Character2, $Character3, $Character4, $Character5, $Character6]

var selected_characters = []

func _input(event : InputEvent) -> void :
	if event.is_action_pressed("right_click"):
		selection.clearArea()
		if len(selected_characters) > 0:
			var destination : Vector2 = event.global_position
			for i in range(len(selected_characters)):
				var character : KinematicBody2D = selected_characters[i]
				if character.selected:
					var path := nav.get_simple_path(character.global_position, destination)
					character.path = path
					character.flock = selected_characters
					character.idling = 0.0

func resetSelected() -> void:
	selected_characters = []

func _ready():
	for character in characters:
		var member = TeamMemberHUD.instance()
		member.set_character(character)
		$Team.add_child(member)

func _on_SelectionArea_area_entered(area: Area2D) -> void:
	var character = area.get_parent()
	if character:
		character.selected = true
		selected_characters.append(character)
