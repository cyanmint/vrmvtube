extends Camera3D

## Camera controller for VRMVTube
## 
## Provides camera controls similar to VRigUnity:
## - Mouse drag to rotate
## - Shift + Mouse drag to pan
## - Mouse wheel to zoom
##
## Created by: GitHub Copilot
## Credits:
## - Inspired by VRigUnity camera controls

@export var rotation_speed: float = 0.3
@export var pan_speed: float = 0.01
@export var zoom_speed: float = 0.5
@export var min_zoom: float = 1.0
@export var max_zoom: float = 10.0

var _is_rotating: bool = false
var _is_panning: bool = false
var _last_mouse_position: Vector2 = Vector2.ZERO
var _camera_distance: float = 3.0
var _camera_rotation: Vector2 = Vector2.ZERO  # x = horizontal, y = vertical
var _pan_offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	_camera_distance = position.z
	_update_camera_transform()

func _input(event: InputEvent) -> void:
	# Mouse button press
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if event.shift_pressed:
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
			var delta := event.position - _last_mouse_position
			_camera_rotation.x -= delta.x * rotation_speed * 0.01
			_camera_rotation.y = clamp(_camera_rotation.y - delta.y * rotation_speed * 0.01, -PI/2 + 0.1, PI/2 - 0.1)
			_last_mouse_position = event.position
			_update_camera_transform()
		elif _is_panning:
			var delta := event.position - _last_mouse_position
			var right := global_transform.basis.x
			var up := global_transform.basis.y
			_pan_offset -= right * delta.x * pan_speed
			_pan_offset += up * delta.y * pan_speed
			_last_mouse_position = event.position
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
