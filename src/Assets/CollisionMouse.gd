extends Area2D

var hover : bool = false

func _on_CollisionMouse_mouse_entered():
	hover = true

func _on_CollisionMouse_mouse_exited():
	hover = false
