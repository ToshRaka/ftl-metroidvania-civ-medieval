extends Node2D

onready var CollisionMouse := $CollisionMouse
onready var HPBar := $MarginContainer/HPBar
onready var AnimationPlayer := $AnimationPlayer

const Y_AXIS := Vector2(0,1)
const VERTICAL_ANIMATION_ANGLE : float = 0.3

signal died
signal hp_changed

var max_hp : float = 200.0
var hp := max_hp setget set_hp

var char_name : String = "Gaston" setget set_charname


var selected : bool = false
var speed : float = 100
var path := PoolVector2Array() setget set_path

func _ready() -> void:
	HPBar.update_hp(hp, max_hp)
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

func set_hp(value : float) -> void:
	hp = value
	if hp <= 0.0:
		hp = 0.0
		emit_signal("died")
	emit_signal("hp_changed", hp, max_hp)

func set_charname(value : String) -> void:
	# Small reminder to implement a name generator :)
	char_name = value

func _unhandled_key_input(event: InputEventKey) -> void:
	# For HP bar testing
	if event.is_action_released("ui_page_down"):
		set_hp(hp - 5*max_hp/100)
