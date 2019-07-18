extends Node2D

onready var CollisionMouse := $CollisionMouse

var selected : bool = false
var speed : float = 100
var path := PoolVector2Array() setget set_path

func _ready() -> void:
	set_process(false)

func _process(delta : float) -> void:
	move_along_path(speed * delta)
	
func move_along_path(distance : float) -> void:
	var point := position
	while path.size():
		var distance_to_target := point.distance_to(path[0])
		if distance <= distance_to_target:
			position = point.linear_interpolate(path[0], distance / distance_to_target)
			break
		distance -= distance_to_target
		point = path[0]
		if distance < 0:
			position = path[0]
			set_process(false)
			break
		path.remove(0)

func set_path(value : PoolVector2Array) -> void:
	path = value
	
	if value.size() == 0:
		return
	set_process(true)
