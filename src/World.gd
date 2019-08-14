extends Node

onready var nav : Navigation2D = $Navigation2D
onready var characters := get_tree().get_nodes_in_group("Allies")
onready var selection : Node = $Selection

const TeamMemberHUD := preload("res://Assets/TeamMemberHUD.tscn")
const Flock := preload("res://Assets/Flock.tscn")

var selected_characters : Array
var select_flock := Flock.instance()
var enemy_flock := Flock.instance()

func _ready():
	for character in get_tree().get_nodes_in_group("Allies"):
		character.set_enemies(get_tree().get_nodes_in_group("Enemies"))
		character.connect("died", self, "_on_Character_died")
		character.connect("navigation_changed", self, "_on_Character_navigation_changed")
	for character in get_tree().get_nodes_in_group("Enemies"):
		character.set_enemies(get_tree().get_nodes_in_group("Allies"))
		character.connect("navigation_changed", self, "_on_Character_navigation_changed")
		
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
	var character := area.get_parent()
	var allies := get_tree().get_nodes_in_group("Allies")
	if character and character.state != character.State.DEAD and allies.has(character):
		selected_characters.append(character)
		
func _on_Flock_navigation_changed(flock : Object, target : Vector2) -> void:
	var path := nav.get_simple_path(flock.centrum(), target)
	path.remove(0)
	flock.path = path
	
func _on_Character_navigation_changed(character : Character, target : Vector2) -> void:
	character.path = nav.get_simple_path(character.global_position, target)

func _on_Character_died(character : Character) -> void:
	selected_characters.erase(character)
