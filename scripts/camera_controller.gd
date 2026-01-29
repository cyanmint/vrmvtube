extends Camera3D

## Camera controller for VRMVTube
## 
## Camera is FIXED at position (0, 1.5, 3) looking at origin
## All pan/rotate/zoom controls transform the MODEL, not the camera
##
## Controls:
## - Mouse drag to rotate model (or pan in pan mode)
## - Scroll/Q/E to scale model (zoom)
## - WASD for model rotation/position based on mode
## - R to toggle pan/rotate mode
## - Pinch to scale (mobile)
##
## Created by: GitHub Copilot

signal mode_changed(is_pan_mode: bool)
signal model_transform_changed(position: Vector3, rotation: Vector3, scale_factor: float)

@export var rotation_speed: float = 0.3
@export var pan_speed: float = 0.01
@export var scale_speed: float = 0.5
@export var keyboard_speed: float = 2.0
@export var min_scale: float = 0.5
@export var max_scale: float = 3.0

var _is_rotating: bool = false
var _is_panning: bool = false
var _is_pan_mode: bool = false  # Toggle between rotate and pan modes
var _last_mouse_position: Vector2 = Vector2.ZERO

# Model transform (these are applied to the model, not camera)
var _model_rotation: Vector3 = Vector3.ZERO  # Euler angles in radians
var _model_position: Vector3 = Vector3(0, -0.5, 0)
var _model_scale: float = 1.5

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

func toggle_pan_mode() -> void:
	"""Toggle between pan and rotate modes"""
	_is_pan_mode = not _is_pan_mode
	mode_changed.emit(_is_pan_mode)
	print("Camera mode: ", "PAN" if _is_pan_mode else "ROTATE")

func get_is_pan_mode() -> bool:
	return _is_pan_mode

func set_model_transform(pos: Vector3, rot: Vector3, scale_val: float) -> void:
	"""Set model transform from saved data"""
	_model_position = pos
	_model_rotation = rot
	_model_scale = scale_val
	_apply_model_transform()

func get_model_transform() -> Dictionary:
	"""Get current model transform"""
	return {
		"position": _model_position,
		"rotation": _model_rotation,
		"scale": _model_scale
	}

func _input(event: InputEvent) -> void:
	# Keyboard hotkeys
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			toggle_pan_mode()
			get_viewport().set_input_as_handled()
			return
	
	# Mouse button press
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Use mode toggle instead of shift key
				if _is_pan_mode:
					_is_panning = true
				else:
					_is_rotating = true
				_last_mouse_position = event.position
			else:
				_is_rotating = false
				_is_panning = false
		
		# Mouse wheel for scale (zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_model_scale = clamp(_model_scale + scale_speed * 0.1, min_scale, max_scale)
			_apply_model_transform()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_model_scale = clamp(_model_scale - scale_speed * 0.1, min_scale, max_scale)
			_apply_model_transform()
	
	# Mouse motion
	elif event is InputEventMouseMotion:
		if _is_rotating:
			var delta: Vector2 = event.position - _last_mouse_position
			# Rotate model around Y axis (horizontal) and X axis (vertical)
			_model_rotation.y -= delta.x * rotation_speed * 0.01
			_model_rotation.x -= delta.y * rotation_speed * 0.01
			# Clamp vertical rotation
			_model_rotation.x = clamp(_model_rotation.x, -PI/2, PI/2)
			_last_mouse_position = event.position
			_apply_model_transform()
		elif _is_panning:
			var delta: Vector2 = event.position - _last_mouse_position
			# Pan model in screen space
			var right: Vector3 = global_transform.basis.x
			var up: Vector3 = global_transform.basis.y
			_model_position -= right * delta.x * pan_speed
			_model_position += up * delta.y * pan_speed
			_last_mouse_position = event.position
			_apply_model_transform()
	
	# Touch/pinch support for mobile
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touch_points[event.index] = event.position
		else:
			_touch_points.erase(event.index)
			_last_pinch_distance = 0.0
	
	elif event is InputEventScreenDrag:
		_touch_points[event.index] = event.position
		
		# Two-finger pinch for scale
		if _touch_points.size() == 2:
			var touch_positions = _touch_points.values()
			var current_distance = touch_positions[0].distance_to(touch_positions[1])
			
			if _last_pinch_distance > 0:
				var delta_distance = current_distance - _last_pinch_distance
				_model_scale = clamp(_model_scale + delta_distance * 0.001, min_scale, max_scale)
				_apply_model_transform()
			
			_last_pinch_distance = current_distance
		# Single finger drag
		elif _touch_points.size() == 1:
			var delta = event.relative
			if _is_pan_mode:
				# Pan mode
				var right: Vector3 = global_transform.basis.x
				var up: Vector3 = global_transform.basis.y
				_model_position -= right * delta.x * pan_speed
				_model_position += up * delta.y * pan_speed
			else:
				# Rotate mode
				_model_rotation.y -= delta.x * rotation_speed * 0.01
				_model_rotation.x -= delta.y * rotation_speed * 0.01
				_model_rotation.x = clamp(_model_rotation.x, -PI/2, PI/2)
			_apply_model_transform()

func _process(delta: float) -> void:
	# Keyboard controls for scale (Q/E)
	if Input.is_key_pressed(KEY_Q):
		_model_scale = clamp(_model_scale - scale_speed * delta, min_scale, max_scale)
		_apply_model_transform()
	elif Input.is_key_pressed(KEY_E):
		_model_scale = clamp(_model_scale + scale_speed * delta, min_scale, max_scale)
		_apply_model_transform()
	
	# WASD controls for pan/rotate based on mode
	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		
		if _is_pan_mode:
			# Pan mode - WASD moves the model
			var right: Vector3 = global_transform.basis.x
			var up: Vector3 = global_transform.basis.y
			_model_position += right * input_vector.x * keyboard_speed * delta * 0.1
			_model_position -= up * input_vector.y * keyboard_speed * delta * 0.1
		else:
			# Rotate mode - WASD rotates the model
			_model_rotation.y += input_vector.x * keyboard_speed * delta
			_model_rotation.x += input_vector.y * keyboard_speed * delta
			_model_rotation.x = clamp(_model_rotation.x, -PI/2, PI/2)
		
		_apply_model_transform()

func _apply_model_transform() -> void:
	"""Apply current transform to model container"""
	if model_container:
		model_container.position = _model_position
		model_container.rotation = _model_rotation
		model_container.scale = Vector3(_model_scale, _model_scale, _model_scale)
		model_transform_changed.emit(_model_position, _model_rotation, _model_scale)
