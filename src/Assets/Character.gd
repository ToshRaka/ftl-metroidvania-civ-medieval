extends Node2D

onready var CollisionMouse := $CollisionMouse
onready var AnimationPlayer := $AnimationPlayer

const Y_AXIS := Vector2(0,1)
const VERTICAL_ANIMATION_ANGLE : float = 0.3

var selected : bool = false
var speed : float = 100
var path := PoolVector2Array() setget set_path

func _ready() -> void:
	set_process(false)

func _process(delta : float) -> void:
	move_along_path(speed * delta)
	
func move_along_path(distance : float) -> void:
	if not path:
		AnimationPlayer.play("Idle")
		return
	var point := position
	while path.size():
		var distance_to_target := point.distance_to(path[0])
		if distance <= distance_to_target:
			position = point.linear_interpolate(path[0], distance / distance_to_target)
			play_move_animation(position - point)
			break
		distance -= distance_to_target
		point = path[0]
		if distance < 0:
			position = path[0]
			set_process(false)
			break
		path.remove(0)
	

func play_move_animation(speed_vector: Vector2) -> void:
	if speed_vector.abs().angle_to(Y_AXIS) < VERTICAL_ANIMATION_ANGLE:
		if speed_vector.y > 0:
			AnimationPlayer.play("Down")
		else:
			AnimationPlayer.play("Up")
	else:
		if speed_vector.x > 0:
			AnimationPlayer.play("Right")
		else:
			AnimationPlayer.play("Left")

func set_path(value : PoolVector2Array) -> void:
	path = value
	
	if value.size() == 0:
		return
	set_process(true)
