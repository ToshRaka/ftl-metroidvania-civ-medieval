extends KinematicBody2D

onready var CollisionMouse := $CollisionMouse
onready var AnimationPlayer := $AnimationPlayer

const Y_AXIS := Vector2(0,1)
const VERTICAL_ANIMATION_ANGLE : float = 0.3

var selected : bool = false
var speed : float = 100
var path := PoolVector2Array() setget set_path
var flock : Array = Array()
var idling : float = 0
var previous_velocity : Vector2 = Vector2()

enum WalkAnim {UP, DOWN, LEFT, RIGHT}
var last_anims : Array = Array()
var duration_anim : float = 0.0

func _ready() -> void:
	for i in range(16):
		last_anims.push_back(WalkAnim.DOWN)

func get_anim() -> int:
	var tmp := [0, 0, 0, 0]
	for anim in last_anims:
		tmp[anim] += 1
	var id_max : int = 0
	var count_max : int = tmp[0]
	for i in range(1, len(tmp)):
		if tmp[i] > count_max:
			count_max = tmp[i]
			id_max = i
	return id_max

# Flock functions
func flock_away_from_others() -> Vector2:
	var v := Vector2(0, 0)
	if len(flock) < 2: # 1 person flock, do nothing
		return v
		
	for other in flock:
		if other == self:
			continue
		var d : Vector2 = other.global_position - global_position
		v -= d.normalized()
	return v.normalized()
	
func flock_centrum() -> Vector2:
	var centrum := Vector2(0, 0)
	for other in flock:
		centrum += other.global_position
	centrum /= len(flock)
	return centrum
	
func flock_cohesion() -> Vector2:
	return (flock_centrum() - global_position).normalized()
	
func flock_dispersion() -> float:
	var centrum : Vector2 = flock_centrum()
	var ret : float = 0.0
	for other in flock:
		ret += (other.global_position - centrum).length()
	return ret / len(flock)

func flock_idling_index() -> int:
	var id_max : int = -1
	var idling_max : float = 0.0
	for i in range(len(flock)):
		var other = flock[i]
		if other.idling > 1 and (id_max == -1 or idling > idling_max):
			id_max = i
			idling_max = other.idling
	return id_max

func _process(delta : float) -> void:
	move_along_path(delta)

func reach_delta(rel : Vector2) -> bool:
	# Try to go to the specified target
	# If there's a collision in between, find a way around
	# Way around = slide along the collision tangent
	
	var collision : KinematicCollision2D = move_and_collide(rel, false)
	if collision:
		var tangent : Vector2 = collision.normal.tangent().normalized()
		var new_rel : Vector2 = (rel.length()-collision.travel.length()) * tangent
		
		play_move_animation(new_rel)
		var collision1 : KinematicCollision2D = move_and_collide(new_rel)
		if collision1:
			previous_velocity = collision.travel + collision1.travel
		else:
			previous_velocity = collision.travel
		return false
	previous_velocity = rel
	play_move_animation(rel)
	return true
	
func move_along_path(delta : float) -> void:
	if not path or path.size() == 0:
		AnimationPlayer.play("Idle")
		idling += delta
		return
	
	var distance : float = speed * delta
	var distance_to_target : float = position.distance_to(path[0])
	
	var to_target : Vector2 = (path[0] - position).normalized()
	var to_away : Vector2 = flock_away_from_others()
	var to_cohesion : Vector2 = flock_cohesion()
	var d : Vector2 = .6 * to_target + .2 * to_away + .2 * to_cohesion
	
	var leader_index : int = flock_idling_index()
	if leader_index > -1:
		if (flock[leader_index].global_position - global_position).length_squared() < len(flock)*len(flock)*32 \
		or flock_dispersion() < 30:
			path.remove(0)
			return
	elif flock_dispersion() < 50:
		d = .2 * to_target + .8 * to_away
		
	var required_rel : Vector2 = d * distance
	var filtered_rel : Vector2 = .8 * required_rel + .2 * previous_velocity
	
	reach_delta(filtered_rel)
	if (global_position-path[0]).length_squared() < 32:
		path.remove(0)

func play_move_animation(speed_vector: Vector2) -> void:
	var anim : int = WalkAnim.DOWN
	if speed_vector.normalized().abs().dot(Y_AXIS) > .7:
		if speed_vector.y > 0:
			pass
		else:
			anim = WalkAnim.UP
	else:
		if speed_vector.x > 0:
			anim = WalkAnim.RIGHT
		else:
			anim = WalkAnim.LEFT
	
	last_anims.push_back(anim)
	last_anims.pop_front()
	
	match get_anim():
		WalkAnim.UP:
			AnimationPlayer.play("Up")
		WalkAnim.DOWN:
			AnimationPlayer.play("Down")
		WalkAnim.LEFT:
			AnimationPlayer.play("Left")
		WalkAnim.RIGHT:
			AnimationPlayer.play("Right")

func set_path(value : PoolVector2Array) -> void:
	path = value
