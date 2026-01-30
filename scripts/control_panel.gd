extends Control
class_name ControlPanel

# UI Control panel for camera and model manipulation

signal mode_changed(new_mode: String)
signal camera_transform_changed(position: Vector3, rotation: Vector3)
signal model_transform_changed(position: Vector3, rotation: Vector3)

enum ControlMode {
	MOVE,
	ROTATE
}

var current_mode := ControlMode.MOVE
var is_dragging := false
var last_mouse_position := Vector2.ZERO
var camera_node: Camera3D
var model_node: Node3D

# UI References
var mode_button: Button
var camera_pos_x: SpinBox
var camera_pos_y: SpinBox
var camera_pos_z: SpinBox
var camera_rot_x: SpinBox
var camera_rot_y: SpinBox
var camera_rot_z: SpinBox
var model_pos_x: SpinBox
var model_pos_y: SpinBox
var model_pos_z: SpinBox
var model_rot_x: SpinBox
var model_rot_y: SpinBox
var model_rot_z: SpinBox
var camera_selector: OptionButton

func _ready() -> void:
	# Find UI elements
	setup_ui_references()

func setup_ui_references() -> void:
	mode_button = get_node_or_null("MarginContainer/VBoxLayoutContainer/ModeButton")
	
	# Camera controls
	camera_pos_x = get_node_or_null("MarginContainer/VBoxLayoutContainer/CameraPanel/CameraPosition/PosX")
	camera_pos_y = get_node_or_null("MarginContainer/VBoxLayoutContainer/CameraPanel/CameraPosition/PosY")
	camera_pos_z = get_node_or_null("MarginContainer/VBoxLayoutContainer/CameraPanel/CameraPosition/PosZ")
	camera_rot_x = get_node_or_null("MarginContainer/VBoxLayoutContainer/CameraPanel/CameraRotation/RotX")
	camera_rot_y = get_node_or_null("MarginContainer/VBoxLayoutContainer/CameraPanel/CameraRotation/RotY")
	camera_rot_z = get_node_or_null("MarginContainer/VBoxLayoutContainer/CameraPanel/CameraRotation/RotZ")
	
	# Model controls
	model_pos_x = get_node_or_null("MarginContainer/VBoxLayoutContainer/ModelPanel/ModelPosition/PosX")
	model_pos_y = get_node_or_null("MarginContainer/VBoxLayoutContainer/ModelPanel/ModelPosition/PosY")
	model_pos_z = get_node_or_null("MarginContainer/VBoxLayoutContainer/ModelPanel/ModelPosition/PosZ")
	model_rot_x = get_node_or_null("MarginContainer/VBoxLayoutContainer/ModelPanel/ModelRotation/RotX")
	model_rot_y = get_node_or_null("MarginContainer/VBoxLayoutContainer/ModelPanel/ModelRotation/RotY")
	model_rot_z = get_node_or_null("MarginContainer/VBoxLayoutContainer/ModelPanel/ModelRotation/RotZ")
	
	# Camera selector
	camera_selector = get_node_or_null("MarginContainer/VBoxLayoutContainer/CameraPanel/CameraSelector")
	
	# Connect signals
	if mode_button:
		mode_button.pressed.connect(_on_mode_button_pressed)
	
	_connect_spinbox_signals()

func _connect_spinbox_signals() -> void:
	# Camera position
	if camera_pos_x:
		camera_pos_x.value_changed.connect(_on_camera_pos_changed)
	if camera_pos_y:
		camera_pos_y.value_changed.connect(_on_camera_pos_changed)
	if camera_pos_z:
		camera_pos_z.value_changed.connect(_on_camera_pos_changed)
	
	# Camera rotation
	if camera_rot_x:
		camera_rot_x.value_changed.connect(_on_camera_rot_changed)
	if camera_rot_y:
		camera_rot_y.value_changed.connect(_on_camera_rot_changed)
	if camera_rot_z:
		camera_rot_z.value_changed.connect(_on_camera_rot_changed)
	
	# Model position
	if model_pos_x:
		model_pos_x.value_changed.connect(_on_model_pos_changed)
	if model_pos_y:
		model_pos_y.value_changed.connect(_on_model_pos_changed)
	if model_pos_z:
		model_pos_z.value_changed.connect(_on_model_pos_changed)
	
	# Model rotation
	if model_rot_x:
		model_rot_x.value_changed.connect(_on_model_rot_changed)
	if model_rot_y:
		model_rot_y.value_changed.connect(_on_model_rot_changed)
	if model_rot_z:
		model_rot_z.value_changed.connect(_on_model_rot_changed)

func set_camera_node(camera: Camera3D) -> void:
	camera_node = camera
	if camera:
		update_camera_ui()

func set_model_node(model: Node3D) -> void:
	model_node = model
	if model:
		update_model_ui()

func update_camera_ui() -> void:
	if not camera_node:
		return
	
	var pos := camera_node.position
	var rot := camera_node.rotation_degrees
	
	if camera_pos_x:
		camera_pos_x.set_value_no_signal(pos.x)
	if camera_pos_y:
		camera_pos_y.set_value_no_signal(pos.y)
	if camera_pos_z:
		camera_pos_z.set_value_no_signal(pos.z)
	if camera_rot_x:
		camera_rot_x.set_value_no_signal(rot.x)
	if camera_rot_y:
		camera_rot_y.set_value_no_signal(rot.y)
	if camera_rot_z:
		camera_rot_z.set_value_no_signal(rot.z)

func update_model_ui() -> void:
	if not model_node:
		return
	
	var pos := model_node.position
	var rot := model_node.rotation_degrees
	
	if model_pos_x:
		model_pos_x.set_value_no_signal(pos.x)
	if model_pos_y:
		model_pos_y.set_value_no_signal(pos.y)
	if model_pos_z:
		model_pos_z.set_value_no_signal(pos.z)
	if model_rot_x:
		model_rot_x.set_value_no_signal(rot.x)
	if model_rot_y:
		model_rot_y.set_value_no_signal(rot.y)
	if model_rot_z:
		model_rot_z.set_value_no_signal(rot.z)

func _on_mode_button_pressed() -> void:
	if current_mode == ControlMode.MOVE:
		current_mode = ControlMode.ROTATE
		mode_button.text = "Mode: Rotate"
	else:
		current_mode = ControlMode.MOVE
		mode_button.text = "Mode: Move"
	
	mode_changed.emit("rotate" if current_mode == ControlMode.ROTATE else "move")

func _on_camera_pos_changed(_value: float) -> void:
	if not camera_node or not camera_pos_x or not camera_pos_y or not camera_pos_z:
		return
	
	var new_pos := Vector3(camera_pos_x.value, camera_pos_y.value, camera_pos_z.value)
	camera_node.position = new_pos
	camera_transform_changed.emit(new_pos, camera_node.rotation_degrees)

func _on_camera_rot_changed(_value: float) -> void:
	if not camera_node or not camera_rot_x or not camera_rot_y or not camera_rot_z:
		return
	
	var new_rot := Vector3(camera_rot_x.value, camera_rot_y.value, camera_rot_z.value)
	camera_node.rotation_degrees = new_rot
	camera_transform_changed.emit(camera_node.position, new_rot)

func _on_model_pos_changed(_value: float) -> void:
	if not model_node or not model_pos_x or not model_pos_y or not model_pos_z:
		return
	
	var new_pos := Vector3(model_pos_x.value, model_pos_y.value, model_pos_z.value)
	model_node.position = new_pos
	model_transform_changed.emit(new_pos, model_node.rotation_degrees)

func _on_model_rot_changed(_value: float) -> void:
	if not model_node or not model_rot_x or not model_rot_y or not model_rot_z:
		return
	
	var new_rot := Vector3(model_rot_x.value, model_rot_y.value, model_rot_z.value)
	model_node.rotation_degrees = new_rot
	model_transform_changed.emit(model_node.position, new_rot)

func populate_camera_list() -> void:
	if not camera_selector:
		return
	
	camera_selector.clear()
	var camera_count := CameraServer.get_feed_count()
	
	if camera_count == 0:
		camera_selector.add_item("No cameras found")
		camera_selector.disabled = true
	else:
		for i in range(camera_count):
			var feed := CameraServer.get_feed(i)
			if feed:
				camera_selector.add_item("Camera %d: %s" % [i, feed.name])
		camera_selector.disabled = false

func _process(_delta: float) -> void:
	# Update model transform display in real-time
	if model_node:
		update_model_ui()
