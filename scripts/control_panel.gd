extends Control
class_name ControlPanel

# UI Control panel for camera and model manipulation

signal mode_changed(new_mode: String)
signal camera_transform_changed(position: Vector3, rotation: Vector3)
signal model_transform_changed(position: Vector3, rotation: Vector3)
signal video_settings_changed()

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

# Video quality UI references
var resolution_selector: OptionButton
var quality_selector: OptionButton
var render_scale_slider: HSlider
var render_scale_label: Label
var msaa_selector: OptionButton
var fxaa_checkbox: CheckBox
var vsync_checkbox: CheckBox
var fps_spinbox: SpinBox

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
	
	# Video quality controls
	resolution_selector = get_node_or_null("MarginContainer/VBoxLayoutContainer/VideoPanel/ResolutionSelector")
	quality_selector = get_node_or_null("MarginContainer/VBoxLayoutContainer/VideoPanel/QualitySelector")
	render_scale_slider = get_node_or_null("MarginContainer/VBoxLayoutContainer/VideoPanel/RenderScaleBox/RenderScaleSlider")
	render_scale_label = get_node_or_null("MarginContainer/VBoxLayoutContainer/VideoPanel/RenderScaleBox/RenderScaleLabel")
	msaa_selector = get_node_or_null("MarginContainer/VBoxLayoutContainer/VideoPanel/MSAASelector")
	fxaa_checkbox = get_node_or_null("MarginContainer/VBoxLayoutContainer/VideoPanel/FXAACheckbox")
	vsync_checkbox = get_node_or_null("MarginContainer/VBoxLayoutContainer/VideoPanel/VSyncCheckbox")
	fps_spinbox = get_node_or_null("MarginContainer/VBoxLayoutContainer/VideoPanel/FPSSpinBox")
	
	# Connect signals
	if mode_button:
		mode_button.pressed.connect(_on_mode_button_pressed)
	
	_connect_spinbox_signals()
	_connect_video_quality_signals()
	_setup_video_quality_options()

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

func _setup_video_quality_options() -> void:
	# Setup resolution options
	if resolution_selector:
		resolution_selector.clear()
		resolution_selector.add_item("640x360 (nHD)", 0)
		resolution_selector.add_item("854x480 (FWVGA)", 1)
		resolution_selector.add_item("1280x720 (HD)", 2)
		resolution_selector.add_item("1920x1080 (Full HD)", 3)
		resolution_selector.add_item("2560x1440 (2K)", 4)
		resolution_selector.add_item("3840x2160 (4K)", 5)
		resolution_selector.select(2)  # Default to 720p
	
	# Setup quality presets
	if quality_selector:
		quality_selector.clear()
		quality_selector.add_item("Low", 0)
		quality_selector.add_item("Medium", 1)
		quality_selector.add_item("High", 2)
		quality_selector.add_item("Ultra", 3)
		quality_selector.select(2)  # Default to High
	
	# Setup MSAA options
	if msaa_selector:
		msaa_selector.clear()
		msaa_selector.add_item("Disabled", 0)
		msaa_selector.add_item("2x MSAA", 1)
		msaa_selector.add_item("4x MSAA", 2)
		msaa_selector.add_item("8x MSAA", 3)
		msaa_selector.select(0)  # Default to disabled
	
	# Setup render scale slider
	if render_scale_slider:
		render_scale_slider.min_value = 0.5
		render_scale_slider.max_value = 2.0
		render_scale_slider.step = 0.1
		render_scale_slider.value = 1.0
		_update_render_scale_label(1.0)
	
	# Setup checkboxes
	if fxaa_checkbox:
		fxaa_checkbox.button_pressed = false
	
	if vsync_checkbox:
		vsync_checkbox.button_pressed = true
	
	# Setup FPS spinbox
	if fps_spinbox:
		fps_spinbox.min_value = 30
		fps_spinbox.max_value = 240
		fps_spinbox.step = 10
		fps_spinbox.value = 60

func _connect_video_quality_signals() -> void:
	if resolution_selector:
		resolution_selector.item_selected.connect(_on_resolution_changed)
	
	if quality_selector:
		quality_selector.item_selected.connect(_on_quality_changed)
	
	if render_scale_slider:
		render_scale_slider.value_changed.connect(_on_render_scale_changed)
	
	if msaa_selector:
		msaa_selector.item_selected.connect(_on_msaa_changed)
	
	if fxaa_checkbox:
		fxaa_checkbox.toggled.connect(_on_fxaa_toggled)
	
	if vsync_checkbox:
		vsync_checkbox.toggled.connect(_on_vsync_toggled)
	
	if fps_spinbox:
		fps_spinbox.value_changed.connect(_on_fps_changed)

func _on_resolution_changed(index: int) -> void:
	video_settings_changed.emit()

func _on_quality_changed(index: int) -> void:
	# Quality presets automatically adjust MSAA, FXAA, and other settings
	match index:
		0:  # Low
			if msaa_selector:
				msaa_selector.select(0)  # Disabled
			if fxaa_checkbox:
				fxaa_checkbox.button_pressed = false
			if render_scale_slider:
				render_scale_slider.value = 0.75
		1:  # Medium
			if msaa_selector:
				msaa_selector.select(0)  # Disabled
			if fxaa_checkbox:
				fxaa_checkbox.button_pressed = true
			if render_scale_slider:
				render_scale_slider.value = 1.0
		2:  # High
			if msaa_selector:
				msaa_selector.select(1)  # 2x MSAA
			if fxaa_checkbox:
				fxaa_checkbox.button_pressed = true
			if render_scale_slider:
				render_scale_slider.value = 1.0
		3:  # Ultra
			if msaa_selector:
				msaa_selector.select(2)  # 4x MSAA
			if fxaa_checkbox:
				fxaa_checkbox.button_pressed = true
			if render_scale_slider:
				render_scale_slider.value = 1.0
	
	video_settings_changed.emit()

func _on_render_scale_changed(value: float) -> void:
	_update_render_scale_label(value)
	video_settings_changed.emit()

func _update_render_scale_label(value: float) -> void:
	if render_scale_label:
		render_scale_label.text = "Render Scale (DPI): %.1fx" % value

func _on_msaa_changed(index: int) -> void:
	video_settings_changed.emit()

func _on_fxaa_toggled(enabled: bool) -> void:
	video_settings_changed.emit()

func _on_vsync_toggled(enabled: bool) -> void:
	video_settings_changed.emit()

func _on_fps_changed(value: float) -> void:
	video_settings_changed.emit()

func get_resolution() -> Vector2i:
	if not resolution_selector:
		return Vector2i(1280, 720)
	
	match resolution_selector.selected:
		0: return Vector2i(640, 360)
		1: return Vector2i(854, 480)
		2: return Vector2i(1280, 720)
		3: return Vector2i(1920, 1080)
		4: return Vector2i(2560, 1440)
		5: return Vector2i(3840, 2160)
		_: return Vector2i(1280, 720)

func get_quality() -> String:
	if not quality_selector:
		return "high"
	
	match quality_selector.selected:
		0: return "low"
		1: return "medium"
		2: return "high"
		3: return "ultra"
		_: return "high"

func get_render_scale() -> float:
	if render_scale_slider:
		return render_scale_slider.value
	return 1.0

func get_msaa() -> String:
	if not msaa_selector:
		return "disabled"
	
	match msaa_selector.selected:
		0: return "disabled"
		1: return "2x"
		2: return "4x"
		3: return "8x"
		_: return "disabled"

func get_fxaa() -> bool:
	if fxaa_checkbox:
		return fxaa_checkbox.button_pressed
	return false

func get_vsync() -> bool:
	if vsync_checkbox:
		return vsync_checkbox.button_pressed
	return true

func get_max_fps() -> int:
	if fps_spinbox:
		return int(fps_spinbox.value)
	return 60
