extends Control

# Main script for VRMVTube application
# Handles UI interactions and coordinates VRM model loading and tracking

@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var vrm_model_node: Node3D = $VBoxContainer/ViewportContainer/SubViewport/VRMModel
@onready var load_vrm_button: Button = $VBoxContainer/ButtonsContainer/LoadVRMButton
@onready var start_tracking_button: Button = $VBoxContainer/ButtonsContainer/StartTrackingButton

var current_vrm_model: Node = null
var tracking_active: bool = false
var default_model_path: String = "res://assets/models/cyanmint.vrm"

func _ready() -> void:
	print("VRMVTube started")
	print("Godot version: ", Engine.get_version_info())
	_update_status("Ready - Load a VRM model to begin")
	start_tracking_button.disabled = true
	
	# Check if plugins are available
	_check_plugins()
	
	# Load default model if available
	if FileAccess.file_exists(default_model_path):
		_update_status("Loading default model...")
		call_deferred("_load_default_model")

func _check_plugins() -> void:
	# Check VRM plugin
	var vrm_available = ClassDB.class_exists("GLTFDocumentExtension")
	print("VRM support available: ", vrm_available)
	
	# Check GDMP plugin (MediaPipe)
	var gdmp_available = ClassDB.class_exists("MediaPipeTask")
	print("GDMP (MediaPipe) support available: ", gdmp_available)
	
	if not vrm_available:
		_update_status("Warning: VRM plugin not detected")
	if not gdmp_available:
		_update_status("Warning: GDMP (MediaPipe) plugin not detected")

func _load_default_model() -> void:
	_on_vrm_file_selected(default_model_path)

func _update_status(message: String) -> void:
	status_label.text = "Status: " + message
	print("[Status] " + message)

func _on_load_vrm_button_pressed() -> void:
	_update_status("Opening file dialog...")
	# Use FileDialog to select VRM file
	var file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter("*.vrm", "VRM Models")
	file_dialog.file_selected.connect(_on_vrm_file_selected)
	file_dialog.canceled.connect(func(): _update_status("File selection canceled"))
	add_child(file_dialog)
	file_dialog.popup_centered_ratio(0.6)

func _on_vrm_file_selected(path: String) -> void:
	_update_status("Loading VRM model: " + path)
	print("Loading VRM from: ", path)
	
	# Clear existing model
	if current_vrm_model:
		vrm_model_node.remove_child(current_vrm_model)
		current_vrm_model.queue_free()
		current_vrm_model = null
	
	# Load VRM model
	# VRM files are automatically imported by godot-vrm plugin as .scn files
	var loaded_scene = load(path)
	if loaded_scene and loaded_scene is PackedScene:
		current_vrm_model = loaded_scene.instantiate()
		vrm_model_node.add_child(current_vrm_model)
		_update_status("VRM model loaded successfully!")
		start_tracking_button.disabled = false
	else:
		_update_status("Failed to load VRM model")
		push_error("Could not load VRM from: " + path)

func _on_start_tracking_button_pressed() -> void:
	tracking_active = not tracking_active
	
	if tracking_active:
		_update_status("Starting MediaPipe tracking...")
		start_tracking_button.text = "Stop Tracking"
		# TODO: Initialize MediaPipe hand/face tracking via GDMP
		_start_tracking()
	else:
		_update_status("Stopping tracking...")
		start_tracking_button.text = "Start Tracking"
		# TODO: Stop MediaPipe tracking
		_stop_tracking()

func _start_tracking() -> void:
	print("Starting tracking (not yet implemented)")
	# TODO: Implement MediaPipe tracking initialization
	_update_status("Tracking started (implementation pending)")

func _stop_tracking() -> void:
	print("Stopping tracking")
	# TODO: Implement tracking cleanup
	_update_status("Tracking stopped")

func _process(_delta: float) -> void:
	if tracking_active:
		# TODO: Update VRM model with tracking data
		pass
