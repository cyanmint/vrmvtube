extends Node3D

## Main scene controller for VRMVTube
## 
## This script handles loading VRM models and basic scene setup.
## Based on V-Sekai's implementation and inspired by VRigUnity.
##
## Created by: GitHub Copilot
## Credits:
## - VRM loading powered by godot-vrm (MIT License, V-Sekai)
## - Inspired by VRigUnity by Kariaro

const DEFAULT_VRM_PATH := "res://example/cyanmint.vrm"

var current_vrm_instance: Node = null

@onready var info_label: Label = $UI/Control/RightPanel/ButtonsPanel/MarginContainer/VBoxContainer/InfoLabel
@onready var platform_info: Label = $UI/Control/RightPanel/BottomPanel/MarginContainer/VBoxContainer/PlatformInfo
@onready var webcam_tracker: Node = $WebcamTracker
@onready var face_rigging: Node = $FaceRigging
@onready var model_container: Node3D = $ModelContainer
@onready var webcam_texture_rect: TextureRect = $UI/Control/RightPanel/WebcamPreviewPanel/MarginContainer/VBoxContainer/WebcamTextureRect
@onready var webcam_status_label: Label = $UI/Control/RightPanel/WebcamPreviewPanel/MarginContainer/VBoxContainer/StatusLabel
@onready var model_controls_panel: PanelContainer = $UI/Control/RightPanel/ModelControlsPanel
@onready var position_y_slider: HSlider = $UI/Control/RightPanel/ModelControlsPanel/MarginContainer/VBoxContainer/PositionYContainer/PositionYSlider
@onready var position_y_value: Label = $UI/Control/RightPanel/ModelControlsPanel/MarginContainer/VBoxContainer/PositionYContainer/PositionYValue
@onready var scale_slider: HSlider = $UI/Control/RightPanel/ModelControlsPanel/MarginContainer/VBoxContainer/ScaleContainer/ScaleSlider
@onready var scale_value: Label = $UI/Control/RightPanel/ModelControlsPanel/MarginContainer/VBoxContainer/ScaleContainer/ScaleValue

func _ready() -> void:
	print("VRMVTube started")
	print("Platform: ", OS.get_name())
	
	# Update platform info in UI
	var platform_name := OS.get_name()
	var vcam_support := ""
	
	# Check virtual camera support
	if platform_name in ["Windows", "Linux", "X11"]:
		print("Virtual camera is supported on this platform")
		vcam_support = " (Virtual Camera: Supported)"
	else:
		print("Virtual camera is NOT supported on this platform")
		vcam_support = " (Virtual Camera: Not Supported)"
	
	if platform_info:
		platform_info.text = "Platform: " + platform_name + vcam_support
	else:
		push_error("Platform info label not found!")
	
	# Connect webcam tracker signals BEFORE it initializes
	if webcam_tracker:
		webcam_tracker.webcam_available.connect(_on_webcam_available)
		print("Main: Connected to webcam signals")
	else:
		push_error("WebcamTracker node not found!")
	
	# Connect model control sliders
	if position_y_slider:
		position_y_slider.value_changed.connect(_on_position_y_changed)
	if scale_slider:
		scale_slider.value_changed.connect(_on_scale_changed)
	
	# Load default VRM model - use call_deferred to ensure scene is ready
	if FileAccess.file_exists(DEFAULT_VRM_PATH):
		print("Loading default VRM model...")
		call_deferred("_load_vrm_model", DEFAULT_VRM_PATH)
	else:
		print("No default VRM model found at: ", DEFAULT_VRM_PATH)
		print("Place a VRM model as 'default.vrm' in the models/ directory for auto-loading")
		# Set info label to show instructions
		if info_label:
			info_label.text = "No model loaded.\nUse 'Load VRM Model' button\nDrag to rotate | Shift+Drag to pan | Scroll to zoom"

func _on_webcam_available(available: bool) -> void:
	"""Handle webcam availability status"""
	if available:
		print("Main: Webcam is available and tracking is active")
		info_label.text = "Webcam tracking active.\n" + info_label.text.split("\n")[-1] if "\n" in info_label.text else info_label.text
		webcam_status_label.text = "Webcam Active"
		
		# Set webcam texture to preview
		var camera_texture = webcam_tracker.get_camera_texture()
		if camera_texture:
			webcam_texture_rect.texture = camera_texture
	else:
		push_warning("Main: Webcam is not available. Using simulated face tracking.")
		info_label.text = "Simulated tracking active.\n" + info_label.text.split("\n")[-1] if "\n" in info_label.text else info_label.text
		webcam_status_label.text = "Simulated Tracking"
		# Show a placeholder image or keep the texture rect empty
		webcam_texture_rect.texture = null

func _on_load_model_button_pressed() -> void:
	"""Show file dialog to select VRM model"""
	$FileDialog.popup_centered()

func _on_file_selected(path: String) -> void:
	"""Load the selected VRM model"""
	_load_vrm_model(path)

func _load_vrm_model(path: String) -> void:
	"""Internal function to load a VRM model from path"""
	print("Loading VRM model from: ", path)
	info_label.text = "Loading VRM model..."
	
	if not FileAccess.file_exists(path):
		var error_msg := "VRM file not found: " + path
		push_error(error_msg)
		info_label.text = "Error: " + error_msg
		return
	
	# Remove previous model if exists
	if current_vrm_instance != null:
		current_vrm_instance.queue_free()
		current_vrm_instance = null
	
	# Load VRM model
	var loaded_scene = load(path)
	if loaded_scene != null:
		current_vrm_instance = loaded_scene.instantiate()
		model_container.add_child(current_vrm_instance)
		
		# Position the model in the container
		if current_vrm_instance is Node3D:
			current_vrm_instance.position = Vector3(0, 0, 0)
			# Scale might need adjustment depending on the VRM model
			current_vrm_instance.scale = Vector3(1, 1, 1)
		
		# Connect model to face rigging
		if face_rigging:
			face_rigging.set_vrm_model(current_vrm_instance)
		
		print("VRM model loaded successfully")
		info_label.text = "VRM model loaded: " + path.get_file() + "\nControls: Drag to rotate | Shift+Drag to pan | Scroll to zoom"
		
		# Show model controls
		if model_controls_panel:
			model_controls_panel.visible = true
	else:
		var error_msg := "Failed to load VRM model"
		push_error(error_msg)
		info_label.text = "Error: " + error_msg

func _on_reset_pose_button_pressed() -> void:
	"""Reset model to default position and scale"""
	if current_vrm_instance and current_vrm_instance is Node3D:
		current_vrm_instance.position = Vector3(0, 0, 0)
		current_vrm_instance.scale = Vector3(1, 1, 1)
		current_vrm_instance.rotation = Vector3(0, 0, 0)
		
		# Reset sliders
		if position_y_slider:
			position_y_slider.value = 0.0
		if scale_slider:
			scale_slider.value = 1.0

func _on_position_y_changed(value: float) -> void:
	"""Update model Y position"""
	if current_vrm_instance and current_vrm_instance is Node3D:
		var new_pos: Vector3 = current_vrm_instance.position
		new_pos.y = value
		current_vrm_instance.position = new_pos
	if position_y_value:
		position_y_value.text = "%.2f" % value

func _on_scale_changed(value: float) -> void:
	"""Update model scale"""
	if current_vrm_instance and current_vrm_instance is Node3D:
		current_vrm_instance.scale = Vector3(value, value, value)
	if scale_value:
		scale_value.text = "%.2f" % value
