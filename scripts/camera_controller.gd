extends Camera3D

## Camera controller for VRMVTube
##
## Camera is FIXED at position (0, 1.5, 3) looking at origin
## All controls transform the MODEL, not the camera
##
## MOVE MODE (R to toggle):
## - Drag or WASD: Move X/Y
## - Q/E/Scroll/Pinch: Move Z
##
## ROTATE MODE (R to toggle):
## - Drag or WASD: Rotate X/Y
## - Q/E/Scroll/Pinch: Rotate Z
##
## Created by: GitHub Copilot

signal mode_changed(is_move_mode: bool)
signal model_transform_changed(position: Vector3, rotation: Vector3, scale_factor: float)

@export var rotation_speed: float = 0.3
@export var position_speed: float = 1.0
@export var rotate_axis_speed: float = 1.0

var _is_dragging: bool = false
var _is_move_mode: bool = true  # true = MOVE mode, false = ROTATE mode
var _last_mouse_position: Vector2 = Vector2.ZERO

# Model transform (these are applied to the model, not camera)
var _model_rotation: Vector3 = Vector3.ZERO  # Euler angles in radians
var _model_position: Vector3 = Vector3(0, -0.5, 0)
var _model_scale: float = 1.0  # Always 1.0 - no scaling

# Touch/pinch support
var _touch_points: Dictionary = {}
var _last_pinch_distance: float = 0.0

# Reference to model container (set by main scene)
var model_container: Node3D = null


func _ready() -> void:
	# Camera is ALWAYS at this fixed position
	position = Vector3(0, 1.5, 3)
	look_at(Vector3.ZERO, Vector3.UP)
	print("Camera fixed at position: ", position)


func set_model_container(container: Node3D) -> void:
	"""Set reference to model container for transformations"""
	model_container = container
	_apply_model_transform()


func toggle_mode() -> void:
	"""Toggle between MOVE and ROTATE modes"""
	_is_move_mode = not _is_move_mode
	mode_changed.emit(_is_move_mode)
	print("Control mode: ", "MOVE" if _is_move_mode else "ROTATE")


func get_is_move_mode() -> bool:
	return _is_move_mode


func set_model_transform(pos: Vector3, rot: Vector3, _scale_val: float) -> void:
	"""Set model transform from saved data"""
	_model_position = pos
	_model_rotation = rot
	# Scale is always 1.0, ignore saved scale value
	_model_scale = 1.0
	_apply_model_transform()


func get_model_transform() -> Dictionary:
	"""Get current model transform"""
	return {"position": _model_position, "rotation": _model_rotation, "scale": _model_scale}


func _is_mouse_over_ui() -> bool:
	"""Check if mouse is currently over the HUD panel"""
	var mouse_pos = get_viewport().get_mouse_position()

	# Get the RightPanel (HUD) node
	var main_scene = get_tree().root.get_node_or_null("Main")
	if not main_scene:
		return false

	var ui_control = main_scene.get_node_or_null("UI/Control/RightPanel")
	if not ui_control or not ui_control is Control:
		return false

	# Check if mouse is within RightPanel bounds
	var ui_rect = ui_control.get_global_rect()
	return ui_rect.has_point(mouse_pos)


func _input(event: InputEvent) -> void:
	# Ignore mouse input if hovering over HUD
	if event is InputEventMouse:
		if _is_mouse_over_ui():
			return

	# Keyboard hotkeys
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			toggle_mode()
			get_viewport().set_input_as_handled()
			return

	# Mouse button press
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging = true
				_last_mouse_position = event.position
			else:
				_is_dragging = false

		# Mouse wheel for Z axis control
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if _is_move_mode:
				# MOVE mode: scroll controls Z position
				_model_position.z += 0.1
			else:
				# ROTATE mode: scroll controls Z rotation (roll)
				_model_rotation.z += 0.1
			_apply_model_transform()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if _is_move_mode:
				# MOVE mode: scroll controls Z position
				_model_position.z -= 0.1
			else:
				# ROTATE mode: scroll controls Z rotation (roll)
				_model_rotation.z -= 0.1
			_apply_model_transform()

	# Mouse motion - behavior depends on mode
	elif event is InputEventMouseMotion:
		if _is_dragging:
			var delta: Vector2 = event.position - _last_mouse_position

			if _is_move_mode:
				# MOVE mode: drag moves X/Y position
				var right: Vector3 = global_transform.basis.x
				var up: Vector3 = global_transform.basis.y
				_model_position -= right * delta.x * position_speed * 0.01
				_model_position += up * delta.y * position_speed * 0.01
			else:
				# ROTATE mode: drag rotates X/Y
				_model_rotation.y -= delta.x * rotation_speed * 0.01
				_model_rotation.x -= delta.y * rotation_speed * 0.01
				# Clamp vertical rotation
				_model_rotation.x = clamp(_model_rotation.x, -PI / 2, PI / 2)

			_last_mouse_position = event.position
			_apply_model_transform()

	# Touch support for mobile
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touch_points[event.index] = event.position
		else:
			_touch_points.erase(event.index)
			_last_pinch_distance = 0.0

	elif event is InputEventScreenDrag:
		_touch_points[event.index] = event.position

		# Two-finger pinch for Z axis control
		if _touch_points.size() == 2:
			var touch_positions = _touch_points.values()
			var current_distance = touch_positions[0].distance_to(touch_positions[1])

			if _last_pinch_distance > 0:
				var delta_distance = current_distance - _last_pinch_distance
				if _is_move_mode:
					# MOVE mode: pinch controls Z position
					_model_position.z += delta_distance * 0.01
				else:
					# ROTATE mode: pinch controls Z rotation (roll)
					_model_rotation.z += delta_distance * 0.01
				_apply_model_transform()

			_last_pinch_distance = current_distance
		# Single finger drag - depends on mode
		elif _touch_points.size() == 1:
			var delta = event.relative

			if _is_move_mode:
				# MOVE mode: drag moves X/Y position
				var right: Vector3 = global_transform.basis.x
				var up: Vector3 = global_transform.basis.y
				_model_position -= right * delta.x * position_speed * 0.01
				_model_position += up * delta.y * position_speed * 0.01
			else:
				# ROTATE mode: drag rotates X/Y
				_model_rotation.y -= delta.x * rotation_speed * 0.01
				_model_rotation.x -= delta.y * rotation_speed * 0.01
				_model_rotation.x = clamp(_model_rotation.x, -PI / 2, PI / 2)

			_apply_model_transform()


func _process(delta: float) -> void:
	var speed = delta

	if _is_move_mode:
		# MOVE MODE
		# W/S = Y position (up/down)
		# A/D = X position (left/right)
		# Q/E = Z position (forward/back)

		if Input.is_key_pressed(KEY_W):
			_model_position.y += position_speed * speed
			_apply_model_transform()
		if Input.is_key_pressed(KEY_S):
			_model_position.y -= position_speed * speed
			_apply_model_transform()

		if Input.is_key_pressed(KEY_A):
			_model_position.x -= position_speed * speed
			_apply_model_transform()
		if Input.is_key_pressed(KEY_D):
			_model_position.x += position_speed * speed
			_apply_model_transform()

		if Input.is_key_pressed(KEY_Q):
			_model_position.z += position_speed * speed
			_apply_model_transform()
		if Input.is_key_pressed(KEY_E):
			_model_position.z -= position_speed * speed
			_apply_model_transform()
	else:
		# ROTATE MODE
		# W/S = X rotation (pitch - tilt forward/back)
		# A/D = Y rotation (yaw - turn left/right)
		# Q/E = Z rotation (roll - lean left/right)

		if Input.is_key_pressed(KEY_W):
			_model_rotation.x += rotate_axis_speed * speed
			_model_rotation.x = clamp(_model_rotation.x, -PI / 2, PI / 2)
			_apply_model_transform()
		if Input.is_key_pressed(KEY_S):
			_model_rotation.x -= rotate_axis_speed * speed
			_model_rotation.x = clamp(_model_rotation.x, -PI / 2, PI / 2)
			_apply_model_transform()

		if Input.is_key_pressed(KEY_A):
			_model_rotation.y += rotate_axis_speed * speed
			_apply_model_transform()
		if Input.is_key_pressed(KEY_D):
			_model_rotation.y -= rotate_axis_speed * speed
			_apply_model_transform()

		if Input.is_key_pressed(KEY_Q):
			_model_rotation.z += rotate_axis_speed * speed
			_apply_model_transform()
		if Input.is_key_pressed(KEY_E):
			_model_rotation.z -= rotate_axis_speed * speed
			_apply_model_transform()


func _apply_model_transform() -> void:
	"""Apply current transform to model container"""
	if model_container:
		model_container.position = _model_position
		model_container.rotation = _model_rotation
		model_container.scale = Vector3(_model_scale, _model_scale, _model_scale)
		model_transform_changed.emit(_model_position, _model_rotation, _model_scale)
