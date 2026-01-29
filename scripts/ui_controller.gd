extends Node

## UI Controller for VRMVTube
##
## Manages all UI interactions and updates, keeping main.gd focused on core logic.
## Handles: sliders, buttons, panels, collapse/expand, status displays
##
## Created by: GitHub Copilot

signal load_model_requested()
signal reset_pose_requested()
signal settings_requested()
signal model_position_changed(position: Vector3)
signal model_rotation_changed(rotation: Vector3)

# UI node references (set by main scene)
var info_label: Label
var platform_info: Label
var webcam_status_label: Label
var metadata_label: RichTextLabel

# Slider and input references
var position_x_slider: HSlider
var position_x_value: LineEdit
var position_y_slider: HSlider
var position_y_value: LineEdit
var position_z_slider: HSlider
var position_z_value: LineEdit
var rotation_x_slider: HSlider
var rotation_x_value: LineEdit
var rotation_y_slider: HSlider
var rotation_y_value: LineEdit
var rotation_z_slider: HSlider
var rotation_z_value: LineEdit

# Panel references
var webcam_content: VBoxContainer
var webcam_collapse_button: Button
var metadata_content: VBoxContainer
var metadata_collapse_button: Button
var right_panel: VBoxContainer
var sidebar_collapse_button: Button
var sidebar_collapse_tab: Button

var camera_mode_button: Button

var _updating_sliders := false  # Prevent slider feedback loops

func _ready() -> void:
	print("UIController: Initialized")

func connect_ui_signals() -> void:
	"""Connect all UI element signals"""
	# Sliders
	if position_x_slider:
		position_x_slider.value_changed.connect(_on_position_x_changed)
	if position_x_value:
		position_x_value.text_submitted.connect(_on_position_x_input)
	
	if position_y_slider:
		position_y_slider.value_changed.connect(_on_position_y_changed)
	if position_y_value:
		position_y_value.text_submitted.connect(_on_position_y_input)
	
	if position_z_slider:
		position_z_slider.value_changed.connect(_on_position_z_changed)
	if position_z_value:
		position_z_value.text_submitted.connect(_on_position_z_input)
	
	if rotation_x_slider:
		rotation_x_slider.value_changed.connect(_on_rotation_x_changed)
	if rotation_x_value:
		rotation_x_value.text_submitted.connect(_on_rotation_x_input)
	
	if rotation_y_slider:
		rotation_y_slider.value_changed.connect(_on_rotation_y_changed)
	if rotation_y_value:
		rotation_y_value.text_submitted.connect(_on_rotation_y_input)
	
	if rotation_z_slider:
		rotation_z_slider.value_changed.connect(_on_rotation_z_changed)
	if rotation_z_value:
		rotation_z_value.text_submitted.connect(_on_rotation_z_input)
	
	# Collapse buttons
	if webcam_collapse_button:
		webcam_collapse_button.pressed.connect(_on_webcam_collapse_pressed)
	if metadata_collapse_button:
		metadata_collapse_button.pressed.connect(_on_metadata_collapse_pressed)
	if sidebar_collapse_button:
		sidebar_collapse_button.pressed.connect(_on_sidebar_collapse_pressed)
	if sidebar_collapse_tab:
		sidebar_collapse_tab.pressed.connect(_on_sidebar_expand_pressed)
	
	print("UIController: Signals connected")

func update_platform_info(platform_name: String, vcam_supported: bool, gdmp_available: bool) -> void:
	"""Update platform information display"""
	if not platform_info:
		return
	
	var vcam_text := " (Virtual Camera: Supported)" if vcam_supported else " (Virtual Camera: Not Supported)"
	var tracking_text := ""
	
	if platform_name in ["Android", "iOS", "Web", "HTML5"]:
		tracking_text = "\n📹 Face Tracking: GDMP Native" if gdmp_available else "\n📹 Face Tracking: Simulated"
	else:
		tracking_text = "\n📹 Face Tracking: Simulated"
	
	platform_info.text = "Platform: " + platform_name + vcam_text + tracking_text

func update_webcam_status(status: String, is_active: bool = false, gdmp_available: bool = false) -> void:
	"""Update webcam status display"""
	if not webcam_status_label:
		return
	
	match status:
		"initializing":
			webcam_status_label.text = "📹 Initializing Camera...\n\nPlease grant camera\npermission when prompted."
		"active":
			webcam_status_label.text = "✅ Camera Active!\n\nMediaPipe tracking active."
		"failed":
			webcam_status_label.text = "❌ Camera Failed\n\nUsing simulated tracking."
		"not_supported":
			webcam_status_label.text = "⚠️ Webcam Preview\nNot Available on Desktop\n\nFace tracking works\nusing simulation mode"
		_:
			webcam_status_label.text = status

func update_tracking_display(tracking_data: Dictionary, gdmp_available: bool) -> void:
	"""Update tracking status display"""
	if not webcam_status_label:
		return
	
	var quality: float = tracking_data.get("tracking_quality", 0.0)
	var source: String = tracking_data.get("source", "unknown")
	
	var status_text := "✅ GDMP Native" if gdmp_available else "🎭 Simulated"
	status_text += "\nQuality: %.0f%%" % (quality * 100.0)
	status_text += "\nSource: " + source
	
	webcam_status_label.text = status_text

func update_model_sliders(pos: Vector3, rot: Vector3) -> void:
	"""Update slider values to match model transform"""
	_updating_sliders = true
	
	if position_x_slider:
		position_x_slider.value = pos.x
	if position_x_value:
		position_x_value.text = "%.2f" % pos.x
	
	if position_y_slider:
		position_y_slider.value = float(pos.y)
	if position_y_value:
		position_y_value.text = "%.2f" % float(pos.y)
	
	if position_z_slider:
		position_z_slider.value = float(pos.z)
	if position_z_value:
		position_z_value.text = "%.2f" % float(pos.z)
	
	if rotation_x_slider:
		rotation_x_slider.value = rad_to_deg(rot.x)
	if rotation_x_value:
		rotation_x_value.text = str(int(rad_to_deg(rot.x))) + "°"
	
	if rotation_y_slider:
		rotation_y_slider.value = rad_to_deg(rot.y)
	if rotation_y_value:
		rotation_y_value.text = str(int(rad_to_deg(rot.y))) + "°"
	
	if rotation_z_slider:
		rotation_z_slider.value = rad_to_deg(rot.z)
	if rotation_z_value:
		rotation_z_value.text = str(int(rad_to_deg(rot.z))) + "°"
	
	_updating_sliders = false

func update_camera_mode_button(is_move_mode: bool) -> void:
	"""Update camera mode button text"""
	if camera_mode_button:
		var mode_text: String = "Mode: MOVE (R)" if is_move_mode else "Mode: ROTATE (R)"
		camera_mode_button.text = mode_text

func update_vrm_metadata(vrm_meta: Variant) -> void:
	"""Display VRM model metadata"""
	if not metadata_label or not vrm_meta:
		return
	
	var text := "[b]VRM Model Information[/b]\n\n"
	
	if vrm_meta.has("title"):
		text += "[b]Title:[/b] " + str(vrm_meta.title) + "\n"
	if vrm_meta.has("version"):
		text += "[b]Version:[/b] " + str(vrm_meta.version) + "\n"
	if vrm_meta.has("author"):
		text += "[b]Author:[/b] " + str(vrm_meta.author) + "\n"
	if vrm_meta.has("license"):
		text += "[b]License:[/b] " + str(vrm_meta.license) + "\n"
	
	metadata_label.text = text

# Slider change handlers - emit signals for main to handle
func _on_position_x_changed(value: float) -> void:
	if _updating_sliders:
		return
	if position_x_value:
		position_x_value.text = "%.2f" % value
	var pos := Vector3(value, position_y_slider.value if position_y_slider else 0.0, position_z_slider.value if position_z_slider else 0.0)
	model_position_changed.emit(pos)

func _on_position_y_changed(value: float) -> void:
	if _updating_sliders:
		return
	if position_y_value:
		position_y_value.text = "%.2f" % value
	var pos := Vector3(position_x_slider.value if position_x_slider else 0.0, value, position_z_slider.value if position_z_slider else 0.0)
	model_position_changed.emit(pos)

func _on_position_z_changed(value: float) -> void:
	if _updating_sliders:
		return
	if position_z_value:
		position_z_value.text = "%.2f" % value
	var pos := Vector3(position_x_slider.value if position_x_slider else 0.0, position_y_slider.value if position_y_slider else 0.0, value)
	model_position_changed.emit(pos)

func _on_rotation_x_changed(value: float) -> void:
	if _updating_sliders:
		return
	if rotation_x_value:
		rotation_x_value.text = str(int(value)) + "°"
	var rot := Vector3(deg_to_rad(value), deg_to_rad(rotation_y_slider.value if rotation_y_slider else 0.0), deg_to_rad(rotation_z_slider.value if rotation_z_slider else 0.0))
	model_rotation_changed.emit(rot)

func _on_rotation_y_changed(value: float) -> void:
	if _updating_sliders:
		return
	if rotation_y_value:
		rotation_y_value.text = str(int(value)) + "°"
	var rot := Vector3(deg_to_rad(rotation_x_slider.value if rotation_x_slider else 0.0), deg_to_rad(value), deg_to_rad(rotation_z_slider.value if rotation_z_slider else 0.0))
	model_rotation_changed.emit(rot)

func _on_rotation_z_changed(value: float) -> void:
	if _updating_sliders:
		return
	if rotation_z_value:
		rotation_z_value.text = str(int(value)) + "°"
	var rot := Vector3(deg_to_rad(rotation_x_slider.value if rotation_x_slider else 0.0), deg_to_rad(rotation_y_slider.value if rotation_y_slider else 0.0), deg_to_rad(value))
	model_rotation_changed.emit(rot)

# Text input handlers
func _on_position_x_input(text: String) -> void:
	if position_x_slider:
		position_x_slider.value = float(text)

func _on_position_y_input(text: String) -> void:
	if position_y_slider:
		position_y_slider.value = float(text)

func _on_position_z_input(text: String) -> void:
	if position_z_slider:
		position_z_slider.value = float(text)

func _on_rotation_x_input(text: String) -> void:
	if rotation_x_slider:
		rotation_x_slider.value = float(text.replace("°", ""))

func _on_rotation_y_input(text: String) -> void:
	if rotation_y_slider:
		rotation_y_slider.value = float(text.replace("°", ""))

func _on_rotation_z_input(text: String) -> void:
	if rotation_z_slider:
		rotation_z_slider.value = float(text.replace("°", ""))

# Panel collapse handlers
func _on_webcam_collapse_pressed() -> void:
	if webcam_content and webcam_collapse_button:
		webcam_content.visible = not webcam_content.visible
		webcam_collapse_button.text = "▼" if webcam_content.visible else "▲"
		_save_panel_state("webcam_hud_visible", webcam_content.visible)

func _on_metadata_collapse_pressed() -> void:
	if metadata_content and metadata_collapse_button:
		metadata_content.visible = not metadata_content.visible
		metadata_collapse_button.text = "▼" if metadata_content.visible else "▲"

func _on_sidebar_collapse_pressed() -> void:
	if right_panel and sidebar_collapse_tab:
		right_panel.visible = false
		sidebar_collapse_tab.visible = true

func _on_sidebar_expand_pressed() -> void:
	if right_panel and sidebar_collapse_tab:
		right_panel.visible = true
		sidebar_collapse_tab.visible = false

func _save_panel_state(key: String, value: bool) -> void:
	"""Save panel visibility state"""
	var config := ConfigFile.new()
	config.load("user://vrmvtube_settings.cfg")
	config.set_value("ui", key, value)
	config.save("user://vrmvtube_settings.cfg")
