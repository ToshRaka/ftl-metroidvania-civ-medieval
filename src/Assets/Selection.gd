extends Node

onready var SelectionRect : ColorRect = $SelectionRect
onready var SelectionArea : Area2D = $SelectionArea
onready var collisionShape : CollisionShape2D = $SelectionArea/CollisionShape2D

var selection_anchor := Vector2()

func _process(delta: float) -> void:
	if selection_anchor:
		var tweaked = tweak_rectangle(selection_anchor, get_viewport().get_mouse_position())
		SelectionRect.set_begin(tweaked[0])
		SelectionRect.set_end(tweaked[1])
		if Input.is_action_just_released("left_click"):
			var rect := RectangleShape2D.new()
			SelectionArea.set_position(tweaked[0]+(tweaked[1]-tweaked[0])/2)
			rect.extents = (tweaked[1]-tweaked[0])/2
			collisionShape.shape = rect
			SelectionRect.visible = false
			selection_anchor = Vector2()
	else:
		if Input.is_action_just_pressed("left_click"):
			var mouse_pos = get_viewport().get_mouse_position()
			selection_anchor = mouse_pos
			SelectionRect.set_begin(mouse_pos)
			SelectionRect.set_end(mouse_pos)
			SelectionRect.visible = true
			$"..".resetSelected()

func tweak_rectangle(begin : Vector2, end : Vector2):
	if begin.x > end.x:
		var temp := begin.x
		begin.x = end.x
		end.x = temp
	
	if begin.y > end.y:
		var temp := begin.y
		begin.y = end.y
		end.y = temp
	
	return [begin, end]

func clearArea() -> void:
	collisionShape.shape = null
