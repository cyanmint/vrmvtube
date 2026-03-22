extends Node3D

## Main scene controller for VRMVTube
##
## Simple VTubing app combining:
## - godot-vrm: VRM model loading and rendering
## - GDMP: MediaPipe face tracking
##
## Inspired by VRigUnity by Kariaro
## Created by: GitHub Copilot

const DEFAULT_VRM_PATH := "res://example/cyanmint.vrm"

# Core components
@onready var gdmp_tracking: Node = $GDMPTracking
@onready var face_rigging: Node = $FaceRigging
@onready var camera_controller: Camera3D = $Camera3D
@onready var model_container: Node3D = $ModelContainer
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var ui_controller: Node = $UIController
@onready var settings_menu: Window = $SettingsMenu

# UI node references - passed to UI controller
@onready
var info_label: Label = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ButtonsPanel/MarginContainer/VBoxContainer/ContentContainer/InfoLabel
@onready
var platform_info: Label = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/BottomPanel/MarginContainer/VBoxContainer/ContentContainer/PlatformInfo
@onready
var webcam_status_label: Label = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/WebcamPreviewPanel/MarginContainer/VBoxContainer/ContentContainer/StatusLabel
@onready
var metadata_label: RichTextLabel = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/MetadataPanel/MarginContainer/VBoxContainer/ContentContainer/ScrollContainer/MetadataLabel

# State
var current_vrm_instance: Node = null


func _ready() -> void:
	print("═══════════════════════════════════════")
	print("    VRMVTube - Simple VTubing App")
	print("═══════════════════════════════════════")
	print("Platform: ", OS.get_name())

	# Set up UI controller
	_setup_ui_controller()

	# Set up camera controller
	if camera_controller:
		camera_controller.model_container = model_container
		camera_controller.mode_changed.connect(_on_camera_mode_changed)
		camera_controller.model_transform_changed.connect(_on_model_transform_changed)

	# Set up GDMP tracking
	if gdmp_tracking:
		gdmp_tracking.tracking_data_received.connect(_on_tracking_data_received)
		gdmp_tracking.camera_started.connect(_on_camera_started)
		gdmp_tracking.camera_failed.connect(_on_camera_failed)

		# Wait for GDMP to initialize
		await get_tree().process_frame

		# Update UI with GDMP status
		var platform_name := OS.get_name()
		var vcam_supported := platform_name in ["Windows", "Linux", "X11"]
		var gdmp_available: bool = gdmp_tracking.is_gdmp_available()

		ui_controller.update_platform_info(platform_name, vcam_supported, gdmp_available)

		if not gdmp_available:
			push_warning("GDMP not available - using simulated tracking")

	# Load settings and model
	_load_settings()
	_load_initial_model()

	print("═══════════════════════════════════════")
	print("Ready! Press L to load VRM, C for settings, R to toggle camera mode")


func _input(event: InputEvent) -> void:
	"""Handle keyboard shortcuts"""
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_L:
				_on_load_model_button_pressed()
				get_viewport().set_input_as_handled()
			KEY_C:
				_on_settings_button_pressed()
				get_viewport().set_input_as_handled()


func _setup_ui_controller() -> void:
	"""Initialize UI controller with node references"""
	if not ui_controller:
		return

	# Set UI node references
	ui_controller.info_label = info_label
	ui_controller.platform_info = platform_info
	ui_controller.webcam_status_label = webcam_status_label
	ui_controller.metadata_label = metadata_label

	# Set slider references
	ui_controller.position_x_slider = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/PositionXContainer/PositionXSlider
	ui_controller.position_x_value = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/PositionXContainer/PositionXValue
	ui_controller.position_y_slider = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/PositionYContainer/PositionYSlider
	ui_controller.position_y_value = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/PositionYContainer/PositionYValue
	ui_controller.position_z_slider = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/PositionZContainer/PositionZSlider
	ui_controller.position_z_value = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/PositionZContainer/PositionZValue
	ui_controller.rotation_x_slider = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/RotationXContainer/RotationXSlider
	ui_controller.rotation_x_value = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/RotationXContainer/RotationXValue
	ui_controller.rotation_y_slider = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/RotationYContainer/RotationYSlider
	ui_controller.rotation_y_value = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/RotationYContainer/RotationYValue
	ui_controller.rotation_z_slider = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/RotationZContainer/RotationZSlider
	ui_controller.rotation_z_value = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/RotationZContainer/RotationZValue

	# Set panel references
	ui_controller.webcam_content = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/WebcamPreviewPanel/MarginContainer/VBoxContainer/ContentContainer
	ui_controller.webcam_collapse_button = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/WebcamPreviewPanel/MarginContainer/VBoxContainer/HeaderContainer/CollapseButton
	ui_controller.metadata_content = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/MetadataPanel/MarginContainer/VBoxContainer/ContentContainer
	ui_controller.metadata_collapse_button = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/MetadataPanel/MarginContainer/VBoxContainer/HeaderContainer/CollapseButton
	ui_controller.right_panel = $UI/Control/RightPanel
	ui_controller.sidebar_collapse_button = $UI/Control/RightPanel/SidebarHeader/MarginContainer/HBoxContainer/SidebarCollapseButton
	ui_controller.sidebar_collapse_tab = $UI/Control/SidebarCollapseTab
	ui_controller.camera_mode_button = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ButtonsPanel/MarginContainer/VBoxContainer/ContentContainer/CameraModeButton

	# Connect UI signals
	ui_controller.connect_ui_signals()
	ui_controller.model_position_changed.connect(_on_model_position_changed)
	ui_controller.model_rotation_changed.connect(_on_model_rotation_changed)

	# Connect button signals
	var load_button = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ButtonsPanel/MarginContainer/VBoxContainer/ContentContainer/LoadModelButton
	if load_button:
		load_button.pressed.connect(_on_load_model_button_pressed)

	var reset_button = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer/ResetPoseButton
	if reset_button:
		reset_button.pressed.connect(_on_reset_pose_button_pressed)

	var settings_button = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ButtonsPanel/MarginContainer/VBoxContainer/ContentContainer/SettingsButton
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)

	if ui_controller.camera_mode_button:
		ui_controller.camera_mode_button.pressed.connect(_on_camera_mode_button_pressed)

	print("UI Controller initialized")


func _load_settings() -> void:
	"""Load and apply saved settings"""
	var config := ConfigFile.new()
	var err := config.load("user://vrmvtube_settings.cfg")

	if err != OK:
		print("No saved settings found, using defaults")
		return

	# Apply graphics settings
	if config.has_section("graphics"):
		var resolution_scale: float = config.get_value("graphics", "resolution_scale", 1.0)
		var msaa: int = config.get_value("graphics", "msaa", 0)
		var vsync: bool = config.get_value("graphics", "vsync", true)

		get_viewport().scaling_3d_scale = resolution_scale
		get_viewport().msaa_3d = msaa
		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
		)

		print(
			"Graphics settings applied: resolution=",
			resolution_scale,
			" msaa=",
			msaa,
			" vsync=",
			vsync
		)

	# Load model transform
	if config.has_section("model") and camera_controller:
		var pos := Vector3(
			config.get_value("model", "position_x", 0.0),
			config.get_value("model", "position_y", -0.5),
			config.get_value("model", "position_z", 0.0)
		)
		var rot := Vector3(
			config.get_value("model", "rotation_x", 0.0),
			config.get_value("model", "rotation_y", 0.0),
			config.get_value("model", "rotation_z", 0.0)
		)

		camera_controller.set_model_transform(pos, rot, 1.0)
		ui_controller.update_model_sliders(pos, rot)
		print("Model transform loaded: pos=", pos, " rot=", rot)


func _load_initial_model() -> void:
	"""Load the default or last used VRM model"""
	var config := ConfigFile.new()
	var model_path := DEFAULT_VRM_PATH

	if config.load("user://vrmvtube_settings.cfg") == OK and config.has_section("model"):
		var saved_path: String = config.get_value("model", "path", DEFAULT_VRM_PATH)
		if FileAccess.file_exists(saved_path):
			model_path = saved_path

	if FileAccess.file_exists(model_path):
		print("Loading VRM model: ", model_path)
		call_deferred("_load_vrm_model", model_path)
	else:
		push_warning("No VRM model found at: ", model_path)
		if info_label:
			info_label.text = "No model loaded. Press L to load a VRM model."


func _load_vrm_model(path: String) -> void:
	"""Load a VRM model using godot-vrm"""
	print("═══ Loading VRM Model ═══")
	print("Path: ", path)

	# Remove existing model
	if current_vrm_instance:
		current_vrm_instance.queue_free()
		current_vrm_instance = null

	# Load VRM using godot-vrm
	var vrm_instance := _load_vrm_runtime(path)
	if not vrm_instance:
		push_error("Failed to load VRM model")
		if info_label:
			info_label.text = "Failed to load VRM model"
		return

	# Add to scene
	model_container.add_child(vrm_instance)
	current_vrm_instance = vrm_instance

	# Connect to face rigging
	if face_rigging:
		face_rigging.set_vrm_model(vrm_instance)

	# Update materials for better rendering
	_update_vrm_materials(vrm_instance)

	# Update UI
	var vrm_meta = vrm_instance.get("vrm_meta")
	if vrm_meta and ui_controller:
		ui_controller.update_vrm_metadata(vrm_meta)

	if info_label:
		info_label.text = "VRM model loaded!"

	# Save as last loaded model
	var config := ConfigFile.new()
	config.load("user://vrmvtube_settings.cfg")
	config.set_value("model", "path", path)
	config.save("user://vrmvtube_settings.cfg")

	print("✅ VRM model loaded successfully")


func _load_vrm_runtime(path: String) -> Node:
	"""Load VRM file at runtime using godot-vrm"""
	# Use godot-vrm's import_vrm script
	var vrm_loader = load("res://addons/vrm/import_vrm.gd").new()

	# Read VRM file
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open VRM file: ", path)
		return null

	var content := file.get_buffer(file.get_length())
	file.close()

	# Import VRM
	var state := GLTFState.new()
	var vrm_extension: GLTFDocumentExtension = load("res://addons/vrm/vrm_extension.gd").new()
	state.add_used_extension("VRM", true)
	state.register_gltf_document_extension(vrm_extension, true)

	var gltf := GLTFDocument.new()
	var err := gltf.append_from_buffer(content, "", state)

	if err != OK:
		push_error("Failed to parse VRM file: ", err)
		return null

	var scene := gltf.generate_scene(state)
	if not scene:
		push_error("Failed to generate VRM scene")
		return null

	return scene


func _update_vrm_materials(node: Node) -> void:
	"""Ensure VRM materials render correctly"""
	if node is MeshInstance3D:
		var mesh := node as MeshInstance3D
		for i in range(mesh.get_surface_override_material_count()):
			var mat := mesh.get_surface_override_material(i)
			if mat:
				# Materials should already be set up by godot-vrm
				pass

	for child in node.get_children():
		_update_vrm_materials(child)


# Event handlers
func _on_tracking_data_received(tracking_data: Dictionary) -> void:
	"""Handle face tracking data from GDMP"""
	if face_rigging:
		face_rigging.apply_tracking_data(tracking_data)

	if ui_controller and gdmp_tracking:
		ui_controller.update_tracking_display(tracking_data, gdmp_tracking.is_gdmp_available())


func _on_camera_started() -> void:
	"""Camera successfully started"""
	print("Camera started successfully!")
	if ui_controller:
		ui_controller.update_webcam_status("active", true, gdmp_tracking.is_gdmp_available())


func _on_camera_failed(reason: String) -> void:
	"""Camera failed to start"""
	push_error("Camera failed: ", reason)
	if ui_controller:
		ui_controller.update_webcam_status("failed")


func _on_camera_mode_changed(is_move_mode: bool) -> void:
	"""Camera mode toggled"""
	if ui_controller:
		ui_controller.update_camera_mode_button(is_move_mode)


func _on_model_transform_changed(pos: Vector3, rot: Vector3, scale_factor: float) -> void:
	"""Model transform changed by camera controller"""
	if ui_controller:
		ui_controller.update_model_sliders(pos, rot)

	# Save transform
	var config := ConfigFile.new()
	config.load("user://vrmvtube_settings.cfg")
	config.set_value("model", "position_x", pos.x)
	config.set_value("model", "position_y", pos.y)
	config.set_value("model", "position_z", pos.z)
	config.set_value("model", "rotation_x", rot.x)
	config.set_value("model", "rotation_y", rot.y)
	config.set_value("model", "rotation_z", rot.z)
	config.save("user://vrmvtube_settings.cfg")


func _on_model_position_changed(pos: Vector3) -> void:
	"""UI position sliders changed"""
	if not camera_controller:
		return

	var current_transform: Dictionary = camera_controller.get_model_transform()
	camera_controller.set_model_transform(pos, current_transform.rotation, current_transform.scale)


func _on_model_rotation_changed(rot: Vector3) -> void:
	"""UI rotation sliders changed"""
	if not camera_controller:
		return

	var current_transform: Dictionary = camera_controller.get_model_transform()
	camera_controller.set_model_transform(current_transform.position, rot, current_transform.scale)


func _on_load_model_button_pressed() -> void:
	"""Open file picker to load VRM model - works on all platforms"""
	var platform := OS.get_name()

	if platform in ["Web", "HTML5"]:
		_open_web_file_picker()
	else:
		# Desktop and Android: use FileDialog with native dialog support (Godot 4.4+)
		_open_native_file_dialog()


func _open_native_file_dialog() -> void:
	"""Open native file dialog (Desktop and Android in Godot 4.4+)"""
	# On Android, request storage permissions before opening dialog
	if OS.get_name() == "Android":
		OS.request_permissions()
		await get_tree().create_timer(0.5).timeout

	var file_dialog := FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.use_native_dialog = true
	file_dialog.filters = PackedStringArray(["*.vrm ; VRM Model Files"])
	file_dialog.file_selected.connect(_on_file_selected)
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))


func _open_web_file_picker() -> void:
	"""Open file picker on Web using JavaScript HTML5 file input.

	Creates an HTML file input element via JavaScriptBridge, reads the selected
	file as an ArrayBuffer, and writes it to the Emscripten virtual filesystem
	so Godot can access it from user://.
	"""
	if not ClassDB.class_exists("JavaScriptBridge"):
		push_error("JavaScriptBridge not available - cannot open file picker on Web")
		if info_label:
			info_label.text = "File picker not available on this platform"
		return

	JavaScriptBridge.eval("""
		(function() {
			var input = document.createElement('input');
			input.type = 'file';
			input.accept = '.vrm';
			input.style.display = 'none';
			document.body.appendChild(input);
			input.onchange = function(e) {
				var file = e.target.files[0];
				if (file) {
					var reader = new FileReader();
					reader.onload = function(evt) {
						var data = new Uint8Array(evt.target.result);
						try {
							FS.writeFile('/userfs/' + file.name, data);
							window._vrmFileName = file.name;
							window._vrmFileReady = true;
						} catch(err) {
							console.error('Failed to write VRM file:', err);
							window._vrmFileReady = false;
						}
					};
					reader.readAsArrayBuffer(file);
				}
				document.body.removeChild(input);
			};
			window._vrmFileReady = false;
			window._vrmFileName = '';
			input.click();
		})();
	""", true)

	# Poll for file data from JavaScript
	_poll_web_file_data()


func _poll_web_file_data() -> void:
	"""Poll for web file picker result and load the VRM model"""
	var max_wait := 60.0
	var elapsed := 0.0

	if info_label:
		info_label.text = "Waiting for file selection..."

	while elapsed < max_wait:
		await get_tree().create_timer(0.2).timeout
		elapsed += 0.2

		var ready = JavaScriptBridge.eval("window._vrmFileReady || false", true)
		if ready:
			var file_name = JavaScriptBridge.eval("window._vrmFileName", true)
			if file_name and file_name != "":
				var load_path := "user://" + str(file_name)
				print("Web file picker: VRM file received: ", load_path)
				# Clear JavaScript state
				JavaScriptBridge.eval(
					"window._vrmFileReady = false; window._vrmFileName = '';",
					true
				)
				_on_file_selected(load_path)
			return

	if info_label:
		info_label.text = "File selection timed out. Press L to try again."


func _on_file_selected(path: String) -> void:
	"""File selected from dialog.

	On Android, copies external storage files to user:// for reliable access.
	On Web, files are already in user:// from the JavaScript file picker.
	"""
	var load_path := path
	var platform := OS.get_name()

	# On Android, copy external files to user:// for reliable access
	if platform == "Android" and not path.begins_with("res://") and not path.begins_with("user://"):
		var dest_path := "user://" + path.get_file()
		var src_file := FileAccess.open(path, FileAccess.READ)
		if src_file:
			var data := src_file.get_buffer(src_file.get_length())
			src_file.close()
			var dst_file := FileAccess.open(dest_path, FileAccess.WRITE)
			if dst_file:
				dst_file.store_buffer(data)
				dst_file.close()
				load_path = dest_path
				print("Copied VRM to user://: ", dest_path)
			else:
				push_warning("Failed to write to user://, loading from original path")
		else:
			push_warning("Failed to read external file, trying direct load")

	_load_vrm_model(load_path)


func _on_reset_pose_button_pressed() -> void:
	"""Reset model to default position and rotation"""
	if camera_controller:
		camera_controller.set_model_transform(Vector3(0, -0.5, 0), Vector3.ZERO, 1.0)
		print("Model pose reset")


func _on_settings_button_pressed() -> void:
	"""Open settings menu"""
	if settings_menu:
		settings_menu.popup_centered()


func _on_camera_mode_button_pressed() -> void:
	"""Toggle camera control mode"""
	if camera_controller:
		camera_controller.toggle_mode()


func _on_settings_applied(settings: Dictionary) -> void:
	"""Settings were applied in settings menu"""
	# Settings are saved automatically by settings_menu
	# Just reload them
	_load_settings()


# Panel collapse/expand handlers
func _on_title_collapse_pressed() -> void:
	var content = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/TitlePanel/MarginContainer/VBoxContainer/ContentContainer
	var button = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/TitlePanel/MarginContainer/VBoxContainer/HeaderContainer/CollapseButton
	if content and button:
		content.visible = not content.visible
		button.text = "▼" if content.visible else "▲"


func _on_webcam_collapse_pressed() -> void:
	# Delegate to UI controller
	if ui_controller:
		ui_controller._on_webcam_collapse_pressed()


func _on_buttons_collapse_pressed() -> void:
	var content = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ButtonsPanel/MarginContainer/VBoxContainer/ContentContainer
	var button = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ButtonsPanel/MarginContainer/VBoxContainer/HeaderContainer/CollapseButton
	if content and button:
		content.visible = not content.visible
		button.text = "▼" if content.visible else "▲"


func _on_model_controls_collapse_pressed() -> void:
	var content = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/ContentContainer
	var button = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/ModelControlsPanel/MarginContainer/VBoxContainer/HeaderContainer/CollapseButton
	if content and button:
		content.visible = not content.visible
		button.text = "▼" if content.visible else "▲"


func _on_metadata_collapse_pressed() -> void:
	# Delegate to UI controller
	if ui_controller:
		ui_controller._on_metadata_collapse_pressed()


func _on_bottom_collapse_pressed() -> void:
	var content = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/BottomPanel/MarginContainer/VBoxContainer/ContentContainer
	var button = $UI/Control/RightPanel/ScrollContainer/PanelsContainer/BottomPanel/MarginContainer/VBoxContainer/HeaderContainer/CollapseButton
	if content and button:
		content.visible = not content.visible
		button.text = "▼" if content.visible else "▲"


func _on_sidebar_collapse_pressed() -> void:
	# Delegate to UI controller
	if ui_controller:
		ui_controller._on_sidebar_collapse_pressed()


func _on_sidebar_expand_pressed() -> void:
	# Delegate to UI controller
	if ui_controller:
		ui_controller._on_sidebar_expand_pressed()
