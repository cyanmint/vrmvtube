extends Control

# Main entry point for VRMVTube application

# Preload custom classes
const Settings = preload("res://scripts/settings.gd")
const HandTrackingManager = preload("res://scripts/hand_tracking_manager.gd")
const FaceTrackingManager = preload("res://scripts/face_tracking_manager.gd")
const ControlPanel = preload("res://scripts/control_panel.gd")

# References
var settings: Settings
var hand_tracking_manager: HandTrackingManager
var face_tracking_manager: FaceTrackingManager
var camera_3d: Camera3D
var vrm_model_node: Node3D
var viewport: SubViewport
var viewport_container: SubViewportContainer
var camera_preview: TextureRect
var status_label: Label
var control_panel: ControlPanel

# Control mode
enum ControlMode {
	MOVE,
	ROTATE
}
var current_mode := ControlMode.MOVE
var is_dragging := false
var last_mouse_position := Vector2.ZERO

# VRM model loading
var vrm_loader: EditorSceneFormatImporter
var current_vrm_path: String = ""

func _ready():
	print("VRMVTube started")
	
	# Initialize settings
	settings = Settings.new()
	add_child(settings)
	
	# Get UI references
	setup_ui_references()
	
	# Setup 3D viewport
	setup_viewport()
	
	# Load default model if auto-load is enabled
	if settings.should_auto_load_model():
		var default_path := settings.get_model_default_path()
		call_deferred("load_vrm_model", default_path)
	
	# Apply camera settings
	apply_camera_settings()
	
	# Setup tracking managers
	setup_tracking_managers()

func setup_ui_references() -> void:
	status_label = get_node_or_null("VBoxContainer/StatusLabel")
	viewport_container = get_node_or_null("VBoxContainer/ContentContainer/ViewportContainer")
	camera_preview = get_node_or_null("VBoxContainer/ContentContainer/CameraPreview")
	control_panel = get_node_or_null("VBoxContainer/ControlPanel")
	
	if control_panel:
		control_panel.mode_changed.connect(_on_mode_changed)
		control_panel.camera_transform_changed.connect(_on_camera_transform_changed)
		control_panel.model_transform_changed.connect(_on_model_transform_changed)

func setup_viewport() -> void:
	if viewport_container:
		viewport = viewport_container.get_node_or_null("SubViewport")
		if viewport:
			camera_3d = viewport.get_node_or_null("Camera3D")
			vrm_model_node = viewport.get_node_or_null("VRMModel")
			
			if control_panel:
				control_panel.set_camera_node(camera_3d)
				control_panel.set_model_node(vrm_model_node)

func setup_tracking_managers() -> void:
	# Create hand tracking manager
	hand_tracking_manager = HandTrackingManager.new()
	add_child(hand_tracking_manager)
	hand_tracking_manager.tracking_error.connect(_on_tracking_error)
	
	# Create face tracking manager
	face_tracking_manager = FaceTrackingManager.new()
	add_child(face_tracking_manager)
	face_tracking_manager.tracking_error.connect(_on_tracking_error)

func connect_face_tracking_signals() -> void:
	# Connect face tracking signals after initialization
	if face_tracking_manager:
		# Use Callable.bind to avoid parse-time type checking issues with MediaPipe types
		face_tracking_manager.connect("face_blendshapes_updated", _on_face_blendshapes_updated)

func apply_camera_settings() -> void:
	if camera_3d and settings:
		camera_3d.position = settings.get_camera_position()
		camera_3d.rotation_degrees = settings.get_camera_rotation()
		
		if control_panel:
			control_panel.update_camera_ui()

func load_vrm_model(path: String) -> void:
	print("[Main] Loading VRM model: ", path)
	
	if not FileAccess.file_exists(path):
		update_status("Error: VRM model not found at " + path)
		push_error("[Main] VRM model file not found: " + path)
		return
	
	# Load VRM model using ResourceLoader
	var loaded_scene = load(path)
	if loaded_scene == null:
		update_status("Error: Failed to load VRM model")
		push_error("[Main] Failed to load VRM model: " + path)
		return
	
	# Clear existing model
	if vrm_model_node and vrm_model_node.get_child_count() > 0:
		for child in vrm_model_node.get_children():
			vrm_model_node.remove_child(child)
			child.queue_free()
	
	# Instance the VRM model
	var model_instance = loaded_scene.instantiate()
	if model_instance:
		vrm_model_node.add_child(model_instance)
		
		# Apply model settings
		if settings:
			vrm_model_node.position = settings.get_model_position()
			vrm_model_node.rotation_degrees = settings.get_model_rotation()
		
		if control_panel:
			control_panel.set_model_node(vrm_model_node)
			control_panel.update_model_ui()
		
		current_vrm_path = path
		update_status("VRM model loaded successfully")
		print("[Main] VRM model loaded successfully")
	else:
		update_status("Error: Failed to instantiate VRM model")
		push_error("[Main] Failed to instantiate VRM model")

func update_status(message: String) -> void:
	if status_label:
		status_label.text = "Status: " + message
	print("[Main] " + message)

func _on_load_vrm_button_pressed():
	# Open file dialog to select VRM model
	var file_dialog := FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.filters = ["*.vrm ; VRM Model Files"]
	file_dialog.file_selected.connect(_on_vrm_file_selected)
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_vrm_file_selected(path: String) -> void:
	load_vrm_model(path)

func _on_start_tracking_button_pressed():
	print("[Main] Starting tracking...")
	update_status("Starting tracking...")
	
	# Connect face tracking signals
	connect_face_tracking_signals()
	
	# Populate camera list
	if control_panel:
		control_panel.populate_camera_list()
	
	# Start hand tracking
	if hand_tracking_manager:
		if hand_tracking_manager.start_tracking():
			update_status("Hand tracking started")
		else:
			update_status("Failed to start hand tracking")
	
	# Start face tracking
	if face_tracking_manager:
		if face_tracking_manager.start_tracking():
			update_status("Face tracking started")

func _on_tracking_error(error_message: String) -> void:
	update_status("Tracking error: " + error_message)
	push_error("[Main] Tracking error: " + error_message)

func _on_face_blendshapes_updated(blendshapes) -> void:
	# Apply blendshapes to VRM model
	# This will be implemented when VRM model has blend shape mesh
	pass

func _on_mode_changed(new_mode: String) -> void:
	if new_mode == "move":
		current_mode = ControlMode.MOVE
	else:
		current_mode = ControlMode.ROTATE
	print("[Main] Control mode changed to: ", new_mode)

func _on_camera_transform_changed(position: Vector3, rotation: Vector3) -> void:
	if settings:
		settings.set_camera_position(position)
		settings.set_camera_rotation(rotation)

func _on_model_transform_changed(position: Vector3, rotation: Vector3) -> void:
	if settings:
		settings.set_model_position(position)
		settings.set_model_rotation(rotation)

func _input(event: InputEvent) -> void:
	if not viewport_container:
		return
	
	# Check if mouse is over viewport
	var viewport_rect := viewport_container.get_global_rect()
	var mouse_pos := get_viewport().get_mouse_position()
	var is_over_viewport := viewport_rect.has_point(mouse_pos)
	
	if not is_over_viewport:
		return
	
	# Handle mouse dragging
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			if event.pressed:
				last_mouse_position = event.position
	
	elif event is InputEventMouseMotion and is_dragging:
		var delta: Vector2 = event.position - last_mouse_position
		last_mouse_position = event.position
		
		if current_mode == ControlMode.MOVE:
			# Move camera X/Y
			if camera_3d:
				var sensitivity := 0.01
				camera_3d.position.x -= delta.x * sensitivity
				camera_3d.position.y += delta.y * sensitivity
				
				if control_panel:
					control_panel.update_camera_ui()
		
		elif current_mode == ControlMode.ROTATE:
			# Rotate camera X/Y
			if camera_3d:
				var sensitivity := 0.5
				camera_3d.rotation_degrees.y -= delta.x * sensitivity
				camera_3d.rotation_degrees.x -= delta.y * sensitivity
				
				if control_panel:
					control_panel.update_camera_ui()
	
	# Handle mouse wheel for Z axis
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var scroll_delta := 0.1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -0.1
			
			if camera_3d:
				if current_mode == ControlMode.MOVE:
					# Move camera Z
					camera_3d.position.z += scroll_delta
				elif current_mode == ControlMode.ROTATE:
					# Rotate camera Z
					camera_3d.rotation_degrees.z += scroll_delta * 10.0
				
				if control_panel:
					control_panel.update_camera_ui()

func _exit_tree() -> void:
	# Save settings on exit
	if settings:
		settings.save_settings()
