extends Camera2D

# Maybe all these const could be exported in the editor
const ZOOM_IN : float = 0.8
const ZOOM_OUT : float = 1.2
const ZOOM_MIN : float = 0.25
const ZOOM_MAX : float = 2.5

const PAN_SPEED_MAX : int = 150
const PAN_ACCELERATION : int = 40

var motion := Vector2(0,0)

func _ready() -> void:
	reset_camera()

func _process(delta: float) -> void:
	var input_x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var input_y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	motion = Vector2(input_x, input_y)*PAN_ACCELERATION
	motion = Vector2(min(motion.x, PAN_SPEED_MAX), min(motion.y, PAN_SPEED_MAX))
	position += motion * zoom

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("ui_accept"):
		reset_camera()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				zoom.x = max(zoom.x * ZOOM_IN, ZOOM_MIN)
				zoom.y = max(zoom.y * ZOOM_IN, ZOOM_MIN)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				zoom.x = min(zoom.x * ZOOM_OUT, ZOOM_MAX)
				zoom.y = min(zoom.y * ZOOM_OUT, ZOOM_MAX)

func reset_camera() -> void:
	# Reser camera to position of the parent
	position = Vector2(0,0)
	zoom = Vector2(1,1)