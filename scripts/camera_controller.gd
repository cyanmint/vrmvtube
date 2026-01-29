extends Camera3D

## Camera controller for VRMVTube
## 
## Provides camera controls:
## - Mouse drag to rotate (or pan in pan mode)
## - Scroll/Q/E to zoom
## - WASD for pan/rotate based on mode
## - R to toggle pan/rotate mode
## - Pinch to zoom (mobile)
##
## Created by: GitHub Copilot
## Credits:
## - Inspired by VRigUnity camera controls

signal mode_changed(is_pan_mode: bool)

@export var rotation_speed: float = 0.3
@export var pan_speed: float = 0.01
@export var zoom_speed: float = 0.5
@export var keyboard_speed: float = 2.0
@export var min_zoom: float = 1.0
@export var max_zoom: float = 10.0

var _is_rotating: bool = false
var _is_panning: bool = false
var _is_pan_mode: bool = false  # Toggle between rotate and pan modes
var _last_mouse_position: Vector2 = Vector2.ZERO
var _camera_distance: float = 3.0
var _camera_rotation: Vector2 = Vector2.ZERO  # x = horizontal, y = vertical
var _pan_offset: Vector3 = Vector3.ZERO

# Touch/pinch support
var _touch_points: Dictionary = {}
var _last_pinch_distance: float = 0.0

func _ready() -> void:
	_camera_distance = position.z
	_update_camera_transform()

func toggle_pan_mode() -> void:
	"""Toggle between pan and rotate modes"""
	_is_pan_mode = not _is_pan_mode
	mode_changed.emit(_is_pan_mode)
	print("Camera mode: ", "PAN" if _is_pan_mode else "ROTATE")

func get_is_pan_mode() -> bool:
	return _is_pan_mode

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
		
		# Mouse wheel for zoom
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_camera_distance = clamp(_camera_distance - zoom_speed, min_zoom, max_zoom)
			_update_camera_transform()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_camera_distance = clamp(_camera_distance + zoom_speed, min_zoom, max_zoom)
			_update_camera_transform()
	
	# Mouse motion
	elif event is InputEventMouseMotion:
		if _is_rotating:
			var delta: Vector2 = event.position - _last_mouse_position
			_camera_rotation.x -= delta.x * rotation_speed * 0.01
			_camera_rotation.y = clamp(_camera_rotation.y - delta.y * rotation_speed * 0.01, -PI/2 + 0.1, PI/2 - 0.1)
			_last_mouse_position = event.position
			_update_camera_transform()
		elif _is_panning:
			var delta: Vector2 = event.position - _last_mouse_position
			var right: Vector3 = global_transform.basis.x
			var up: Vector3 = global_transform.basis.y
			_pan_offset -= right * delta.x * pan_speed
			_pan_offset += up * delta.y * pan_speed
			_last_mouse_position = event.position
			_update_camera_transform()
	
	# Touch/pinch support for mobile
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touch_points[event.index] = event.position
		else:
			_touch_points.erase(event.index)
			_last_pinch_distance = 0.0
	
	elif event is InputEventScreenDrag:
		_touch_points[event.index] = event.position
		
		# Two-finger pinch for zoom
		if _touch_points.size() == 2:
			var touch_positions = _touch_points.values()
			var current_distance = touch_positions[0].distance_to(touch_positions[1])
			
			if _last_pinch_distance > 0:
				var delta_distance = current_distance - _last_pinch_distance
				_camera_distance = clamp(_camera_distance - delta_distance * 0.01, min_zoom, max_zoom)
				_update_camera_transform()
			
			_last_pinch_distance = current_distance
		# Single finger drag
		elif _touch_points.size() == 1:
			var delta = event.relative
			if _is_pan_mode:
				# Pan mode
				var right: Vector3 = global_transform.basis.x
				var up: Vector3 = global_transform.basis.y
				_pan_offset -= right * delta.x * pan_speed
				_pan_offset += up * delta.y * pan_speed
			else:
				# Rotate mode
				_camera_rotation.x -= delta.x * rotation_speed * 0.01
				_camera_rotation.y = clamp(_camera_rotation.y - delta.y * rotation_speed * 0.01, -PI/2 + 0.1, PI/2 - 0.1)
			_update_camera_transform()

func _process(delta: float) -> void:
	# Keyboard controls for zoom (Q/E)
	if Input.is_key_pressed(KEY_Q):
		_camera_distance = clamp(_camera_distance - zoom_speed * delta * 3.0, min_zoom, max_zoom)
		_update_camera_transform()
	elif Input.is_key_pressed(KEY_E):
		_camera_distance = clamp(_camera_distance + zoom_speed * delta * 3.0, min_zoom, max_zoom)
		_update_camera_transform()
	
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
			# Pan mode - WASD moves the camera
			var right: Vector3 = global_transform.basis.x
			var up: Vector3 = global_transform.basis.y
			_pan_offset += right * input_vector.x * keyboard_speed * delta
			_pan_offset -= up * input_vector.y * keyboard_speed * delta
		else:
			# Rotate mode - WASD rotates the camera
			_camera_rotation.x += input_vector.x * keyboard_speed * delta
			_camera_rotation.y = clamp(_camera_rotation.y + input_vector.y * keyboard_speed * delta, -PI/2 + 0.1, PI/2 - 0.1)
		
		_update_camera_transform()

func _update_camera_transform() -> void:
	"""Update camera position based on rotation, distance, and pan offset"""
	var target_position := Vector3.ZERO + _pan_offset
	
	# Calculate position based on rotation
	var offset := Vector3.ZERO
	offset.x = cos(_camera_rotation.y) * sin(_camera_rotation.x)
	offset.y = sin(_camera_rotation.y)
	offset.z = cos(_camera_rotation.y) * cos(_camera_rotation.x)
	
	position = target_position + offset * _camera_distance
	look_at(target_position, Vector3.UP)
