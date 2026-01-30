extends Control

# Main entry point for VRMVTube application

# Preload custom classes
const Settings = preload("res://scripts/settings.gd")
# Load tracking managers conditionally to avoid MediaPipe dependency issues
# const HandTrackingManager = preload("res://scripts/hand_tracking_manager.gd")
# const FaceTrackingManager = preload("res://scripts/face_tracking_manager.gd")
const ControlPanel = preload("res://scripts/control_panel.gd")

# References
var settings: Settings
var hand_tracking_manager # : HandTrackingManager
var face_tracking_manager # : FaceTrackingManager
var camera_3d: Camera3D
var vrm_model_node: Node3D
var viewport: SubViewport
var viewport_container: SubViewportContainer
var camera_preview: TextureRect
var status_label: Label
var control_panel: ControlPanel
var settings_hud: PanelContainer
var collapse_button: Button
var show_hud_button: Button
var settings_scroll_container: ScrollContainer
var is_settings_collapsed := false

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
	
	# Connect to window resize signal to update viewport
	get_tree().root.size_changed.connect(_on_window_size_changed)
	
	# Load default model if auto-load is enabled
	if settings.should_auto_load_model():
		var default_path := settings.get_model_default_path()
		call_deferred("load_vrm_model", default_path)
	
	# Apply camera settings
	apply_camera_settings()
	
	# Setup tracking managers
	setup_tracking_managers()

func setup_ui_references() -> void:
	status_label = get_node_or_null("HUDOverlay/VBoxContainer/ScrollContainer/ContentVBox/StatusSection/StatusLabel")
	viewport_container = get_node_or_null("ViewportContainer")
	camera_preview = get_node_or_null("HUDOverlay/VBoxContainer/ScrollContainer/ContentVBox/TrackingSection/CameraPreview")
	settings_hud = get_node_or_null("HUDOverlay")
	collapse_button = get_node_or_null("HUDOverlay/VBoxContainer/Header/CollapseButton")
	show_hud_button = get_node_or_null("ShowHUDButton")
	settings_scroll_container = get_node_or_null("HUDOverlay/VBoxContainer/ScrollContainer")
	control_panel = get_node_or_null("HUDOverlay/VBoxContainer/ScrollContainer/ContentVBox/SettingsSection/ControlPanel")
	
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
			
			# Set up green screen background (chroma key green)
			var world_env = viewport.get_node_or_null("WorldEnvironment")
			if world_env:
				var environment = Environment.new()
				environment.background_mode = Environment.BG_COLOR
				environment.background_color = Color(0.0, 1.0, 0.0)  # Pure green #00FF00
				world_env.environment = environment
			
			# Update viewport size to match container on initial setup
			_update_viewport_size()
			
			if control_panel:
				control_panel.set_camera_node(camera_3d)
				control_panel.set_model_node(vrm_model_node)

func _on_window_size_changed() -> void:
	# Update SubViewport size when window is resized
	# This ensures the viewport properly adapts to portrait/landscape changes
	_update_viewport_size()

func _update_viewport_size() -> void:
	# Update the SubViewport to match the container size
	# This is necessary for proper aspect ratio handling in portrait/landscape modes
	if viewport_container and viewport:
		var container_size = viewport_container.size
		if container_size.x > 0 and container_size.y > 0:
			viewport.size = Vector2i(int(container_size.x), int(container_size.y))
			print("[Main] Viewport resized to: ", viewport.size)

func setup_tracking_managers() -> void:
	# Create hand tracking manager (if GDMP is available)
	if ClassDB.class_exists("MediaPipeHandLandmarker"):
		var HandTrackingManager = load("res://scripts/hand_tracking_manager.gd")
		if HandTrackingManager:
			hand_tracking_manager = HandTrackingManager.new()
			add_child(hand_tracking_manager)
			hand_tracking_manager.connect("tracking_error", _on_tracking_error)
	else:
		print("[Main] MediaPipe not available, hand tracking disabled")
	
	# Create face tracking manager (if GDMP is available)
	if ClassDB.class_exists("MediaPipeFaceLandmarker"):
		var FaceTrackingManager = load("res://scripts/face_tracking_manager.gd")
		if FaceTrackingManager:
			face_tracking_manager = FaceTrackingManager.new()
			add_child(face_tracking_manager)
			face_tracking_manager.connect("tracking_error", _on_tracking_error)
	else:
		print("[Main] MediaPipe not available, face tracking disabled")

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
	file_dialog.close_requested.connect(func(): file_dialog.queue_free())
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_vrm_file_selected(path: String) -> void:
	load_vrm_model(path)
	# Clean up the file dialog after selection
	var file_dialog = get_node_or_null("FileDialog")
	if file_dialog:
		file_dialog.queue_free()

func _on_start_tracking_button_pressed():
	print("[Main] Starting tracking...")
	update_status("Starting tracking...")
	
	# Connect face tracking signals
	connect_face_tracking_signals()
	
	# Populate camera list
	if control_panel:
		control_panel.populate_camera_list()
	
	# Start hand tracking
	if hand_tracking_manager and hand_tracking_manager.has_method("start_tracking"):
		if hand_tracking_manager.start_tracking():
			update_status("Hand tracking started")
			# Connect hand landmarks signal
			if hand_tracking_manager.has_signal("hand_landmarks_updated"):
				hand_tracking_manager.connect("hand_landmarks_updated", _on_hand_landmarks_updated)
		else:
			update_status("Failed to start hand tracking")
	
	# Start face tracking
	if face_tracking_manager and face_tracking_manager.has_method("start_tracking"):
		if face_tracking_manager.start_tracking():
			update_status("Face tracking started")

func _on_collapse_button_pressed():
	# Toggle HUD panel collapse/expand
	# When collapsed, completely hide the HUD and show the "Show HUD" button
	is_settings_collapsed = !is_settings_collapsed
	
	if is_settings_collapsed:
		# Collapse: hide entire HUD overlay, show reopen button
		if settings_hud:
			settings_hud.visible = false
		if show_hud_button:
			show_hud_button.visible = true
	else:
		# Expand: show HUD overlay, hide reopen button
		if settings_hud:
			settings_hud.visible = true
		if show_hud_button:
			show_hud_button.visible = false

func _on_show_hud_button_pressed():
	# Reopen the HUD when the "Show HUD" button is clicked
	is_settings_collapsed = false
	if settings_hud:
		settings_hud.visible = true
	if show_hud_button:
		show_hud_button.visible = false

func _on_tracking_error(error_message: String) -> void:
	update_status("Tracking error: " + error_message)
	push_error("[Main] Tracking error: " + error_message)

func _on_face_blendshapes_updated(blendshapes) -> void:
	# Apply blendshapes to VRM model
	if not vrm_model_node or vrm_model_node.get_child_count() == 0:
		return
	
	var model_instance = vrm_model_node.get_child(0)
	if not model_instance:
		return
	
	# Find the mesh instance with blendshapes
	var mesh_instances = _find_nodes_by_type(model_instance, "MeshInstance3D")
	for mesh_instance in mesh_instances:
		if mesh_instance.mesh and mesh_instance.mesh.get_blend_shape_count() > 0:
			# Apply blendshapes from MediaPipe to VRM mesh
			_apply_blendshapes_to_mesh(mesh_instance, blendshapes)

func _on_hand_landmarks_updated(landmarks: Array) -> void:
	# Apply hand landmarks to VRM model hand bones
	if not vrm_model_node or vrm_model_node.get_child_count() == 0:
		return
	
	var model_instance = vrm_model_node.get_child(0)
	if not model_instance:
		return
	
	# Find skeleton and apply hand tracking
	var skeleton = _find_node_by_type(model_instance, "Skeleton3D")
	if skeleton:
		_apply_hand_tracking_to_skeleton(skeleton, landmarks)

# Helper function to find nodes by type
func _find_nodes_by_type(root: Node, type: String) -> Array:
	var result = []
	if root.is_class(type):
		result.append(root)
	for child in root.get_children():
		result.append_array(_find_nodes_by_type(child, type))
	return result

func _find_node_by_type(root: Node, type: String) -> Node:
	if root.is_class(type):
		return root
	for child in root.get_children():
		var found = _find_node_by_type(child, type)
		if found:
			return found
	return null

func _apply_blendshapes_to_mesh(mesh_instance: MeshInstance3D, blendshapes) -> void:
	# This function applies MediaPipe blendshapes to VRM mesh
	# MediaPipe provides blendshapes as classifications
	if not blendshapes or not blendshapes.has_method("get_categories"):
		return
	
	var categories = blendshapes.get_categories() if blendshapes.has_method("get_categories") else []
	if categories.is_empty():
		return
		
	# Map MediaPipe blendshape names to VRM blend shape indices
	for category in categories:
		var shape_name = category.category_name if category.has_method("get_category_name") else ""
		var shape_value = category.score if category.has("score") else 0.0
		
		# Try to find matching blend shape in mesh
		var mesh = mesh_instance.mesh
		for i in range(mesh.get_blend_shape_count()):
			var blend_name = mesh.get_blend_shape_name(i)
			# Simple name matching - can be improved with better mapping
			if blend_name.to_lower().contains(shape_name.to_lower()):
				mesh_instance.set_blend_shape_value(i, shape_value)
				break

func _apply_hand_tracking_to_skeleton(skeleton: Skeleton3D, landmarks: Array) -> void:
	# This function applies MediaPipe hand landmarks to VRM skeleton bones
	# landmarks is an array of hand landmark data
	if landmarks.is_empty():
		return
	
	# Get the first hand (you can extend this for both hands)
	var hand_data = landmarks[0] if landmarks.size() > 0 else null
	if not hand_data:
		return
	
	# Map MediaPipe hand landmarks to VRM finger bones
	# This is a simplified version - full implementation would map each finger joint
	var finger_bone_mapping = {
		"LeftThumb": [1, 2, 3, 4],  # Thumb landmarks
		"LeftIndex": [5, 6, 7, 8],  # Index finger landmarks
		"LeftMiddle": [9, 10, 11, 12],  # Middle finger landmarks
		"LeftRing": [13, 14, 15, 16],  # Ring finger landmarks
		"LeftLittle": [17, 18, 19, 20],  # Pinky landmarks
	}
	
	# Apply rotations to finger bones based on landmarks
	# This is a placeholder - actual implementation would calculate proper rotations
	# from landmark positions
	for bone_name in finger_bone_mapping:
		var bone_idx = skeleton.find_bone(bone_name)
		if bone_idx != -1:
			# Calculate rotation based on landmarks (simplified)
			# In a real implementation, you would calculate the rotation
			# from the landmark positions
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
	
	# Check if mouse is over HUD overlay - if so, don't handle camera/model input
	# This prevents dragging on the HUD from also dragging the camera/model
	if settings_hud and settings_hud.visible:
		var hud_rect := settings_hud.get_global_rect()
		if hud_rect.has_point(mouse_pos):
			# Mouse is over HUD - let HUD controls handle input
			return
	
	# Also check if mouse is over the show HUD button
	if show_hud_button and show_hud_button.visible:
		var button_rect := show_hud_button.get_global_rect()
		if button_rect.has_point(mouse_pos):
			# Mouse is over button - let button handle input
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
				
				# Save camera position to settings
				if settings:
					settings.set_camera_position(camera_3d.position)
		
		elif current_mode == ControlMode.ROTATE:
			# Rotate camera X/Y
			if camera_3d:
				var sensitivity := 0.5
				camera_3d.rotation_degrees.y -= delta.x * sensitivity
				camera_3d.rotation_degrees.x -= delta.y * sensitivity
				
				if control_panel:
					control_panel.update_camera_ui()
				
				# Save camera rotation to settings
				if settings:
					settings.set_camera_rotation(camera_3d.rotation_degrees)
	
	# Handle mouse wheel for Z axis
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var scroll_delta := 0.1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -0.1
			
			if camera_3d:
				if current_mode == ControlMode.MOVE:
					# Move camera Z
					camera_3d.position.z += scroll_delta
					# Save camera position to settings
					if settings:
						settings.set_camera_position(camera_3d.position)
				elif current_mode == ControlMode.ROTATE:
					# Rotate camera Z
					camera_3d.rotation_degrees.z += scroll_delta * 10.0
					# Save camera rotation to settings
					if settings:
						settings.set_camera_rotation(camera_3d.rotation_degrees)
				
				if control_panel:
					control_panel.update_camera_ui()

func _exit_tree() -> void:
	# Save settings on exit
	if settings:
		settings.save_settings()
