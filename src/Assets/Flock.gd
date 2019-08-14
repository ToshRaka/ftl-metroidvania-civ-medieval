extends Node

signal navigation_changed

var characters : Array
var path := PoolVector2Array()

func init(ch : Array) -> void:
	# First, disconnect from potential previous characters
	for character in characters:
		character.disconnect("died", self, "_on_Character_quit")
		character.disconnect("quit_flock", self, "_on_Character_quit")
	
	characters = ch
	for character in characters:
		character.set_flock(self)
		character.connect("died", self, "_on_Character_quit")
		character.connect("quit_flock", self, "_on_Character_quit")
		
func set_target(target : Vector2) -> void:
	emit_signal("navigation_changed", self, target)
	for character in characters:
		character.state_move_to_target(path)

func away_from_others(character : Object) -> Vector2:
	var v := Vector2(0, 0)
	if len(characters) < 2: # 1 person flock, do nothing
		return v
		
	for other in characters:
		if other == character:
			continue
		var d : Vector2 = other.global_position - character.global_position
		v -= d.normalized()
	return v.normalized()
	
func centrum() -> Vector2:
	var centrum := Vector2(0, 0)
	for other in characters:
		centrum += other.global_position
	centrum /= len(characters)
	return centrum
	
func cohesion(character : Object) -> Vector2:
	return (centrum() - character.global_position).normalized()
	
func dispersion() -> float:
	var centrum : Vector2 = centrum()
	var ret : float = 0.0
	for other in characters:
		ret += (other.global_position - centrum).length()
	return ret / len(characters)

func idling_index() -> int:
	var id_max : int = -1
	var idling_max : float = 0.0
	for i in range(len(characters)):
		var other = characters[i]
		if other.idling > 1 and (id_max == -1 or other.idling > idling_max):
			id_max = i
			idling_max = other.idling
	return id_max
	
func size() -> int:
	return len(characters)

func _on_Character_quit(character : Character) -> void:
	characters.erase(character)
	print("Remaining characters : ", characters.size())