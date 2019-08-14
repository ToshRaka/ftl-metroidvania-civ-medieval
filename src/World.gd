extends Node

onready var nav : Navigation2D = $Navigation2D
onready var characters := get_tree().get_nodes_in_group("Allies")

const TeamMemberHUD := preload("res://Assets/TeamMemberHUD.tscn")
const Flock := preload("res://Assets/Flock.tscn")

onready var selection : Node = $Selection
onready var characters := [$Character1, $Character2, $Character3, $Character4, $Character5, $Character6]

var selected_characters = []
var select_flock := Flock.instance()

var enemy_flock := Flock.instance()

func _ready():
	for character in get_tree().get_nodes_in_group("Allies"):
		character.set_enemies(get_tree().get_nodes_in_group("Enemies"))
		#character.connect("navigation_changed", self, "_on_Character_navigation_changed")
	for character in get_tree().get_nodes_in_group("Enemies"):
		character.set_enemies(get_tree().get_nodes_in_group("Allies"))
		#character.connect("navigation_changed", self, "_on_Character_navigation_changed")
		
	select_flock.connect("navigation_changed", self, "_on_Flock_navigation_changed")
	add_child(select_flock)
	
	enemy_flock.init(get_tree().get_nodes_in_group("Enemies"))
	add_child(enemy_flock)
	
	# HUD
	for character in characters:
		var member = TeamMemberHUD.instance()
		member.set_character(character)
		$Team.add_child(member)

func _input(event : InputEvent) -> void :
	if event.is_action_pressed("right_click"):
		selection.clearArea()
		if len(selected_characters) > 0:
			var destination : Vector2 = event.global_position
      select_flock.init(selected_characters)
      select_flock.set_target(destination)

func resetSelected() -> void:
	selected_characters = []

func _on_SelectionArea_area_entered(area: Area2D) -> void:
	var character = area.get_parent()
	if character:
		character.selected = true
		selected_characters.append(character)
