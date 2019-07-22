extends KinematicBody2D

onready var CollisionMouse := $CollisionMouse
onready var AnimationPlayer := $AnimationPlayer

const Y_AXIS := Vector2(0,1)
const VERTICAL_ANIMATION_ANGLE : float = 0.3

var selected : bool = false
var speed : float = 100
var path := PoolVector2Array() setget set_path

func _process(delta : float) -> void:
	move_along_path(delta)

func orthogonal(v : Vector2) -> Vector2:
	return Vector2(v.y, -v.x)

func reach_delta(rel : Vector2) -> bool:
	# Try to go to the specified target
	# If there's a collision in between, find a way around
	# Way around = slide along the collision tangent
	
	var collision : KinematicCollision2D = move_and_collide(rel)
	if collision:
		var tangent : Vector2 = orthogonal(collision.normal)
		var s : int = sign(collision.collider_velocity.dot(tangent))
		var new_rel : Vector2 = rel.abs() * tangent
		
		# When the collider is moving, try to move towards it to get passed them quickly
		if s != 0:
			new_rel *= -s
		move_and_collide(new_rel)
		return false
	return true
	
func move_along_path(delta : float) -> void:
	if not path or path.size() == 0:
		AnimationPlayer.play("Idle")
		return
	
	var distance : float = speed * delta
	var distance_to_target : float = position.distance_to(path[0])
	
	var d : Vector2 = (path[0] - position).normalized()
	
	play_move_animation(d)
	if distance >= distance_to_target:
		reach_delta(d * distance_to_target)
		path.remove(0)
	else:
		reach_delta(d * distance)

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
