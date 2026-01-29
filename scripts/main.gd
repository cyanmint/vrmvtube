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
var sidebar_collapsed := false

@onready var info_label: Label = $UI/Control/RightPanel/ButtonsPanel/MarginContainer/VBoxContainer/InfoLabel
@onready var platform_info: Label = $UI/Control/RightPanel/BottomPanel/MarginContainer/VBoxContainer/PlatformInfo
@onready var webcam_tracker: Node = $WebcamTracker
@onready var face_rigging: Node = $FaceRigging
@onready var model_container: Node3D = $ModelContainer
@onready var webcam_texture_rect: TextureRect = $UI/Control/RightPanel/WebcamPreviewPanel/MarginContainer/VBoxContainer/ContentContainer/WebcamTextureRect
@onready var webcam_status_label: Label = $UI/Control/RightPanel/WebcamPreviewPanel/MarginContainer/VBoxContainer/ContentContainer/StatusLabel
@onready var webcam_preview_panel: PanelContainer = $UI/Control/RightPanel/WebcamPreviewPanel
@onready var webcam_collapse_button: Button = $UI/Control/RightPanel/WebcamPreviewPanel/MarginContainer/VBoxContainer/HeaderContainer/CollapseButton
@onready var webcam_content: VBoxContainer = $UI/Control/RightPanel/WebcamPreviewPanel/MarginContainer/VBoxContainer/ContentContainer
@onready var buttons_panel: PanelContainer = $UI/Control/RightPanel/ButtonsPanel
@onready var model_controls_panel: PanelContainer = $UI/Control/RightPanel/ModelControlsPanel
@onready var bottom_panel: PanelContainer = $UI/Control/RightPanel/BottomPanel
@onready var position_y_slider: HSlider = $UI/Control/RightPanel/ModelControlsPanel/MarginContainer/VBoxContainer/PositionYContainer/PositionYSlider
@onready var position_y_value: Label = $UI/Control/RightPanel/ModelControlsPanel/MarginContainer/VBoxContainer/PositionYContainer/PositionYValue
@onready var scale_slider: HSlider = $UI/Control/RightPanel/ModelControlsPanel/MarginContainer/VBoxContainer/ScaleContainer/ScaleSlider
@onready var scale_value: Label = $UI/Control/RightPanel/ModelControlsPanel/MarginContainer/VBoxContainer/ScaleContainer/ScaleValue
@onready var settings_menu: Window = $SettingsMenu
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var right_panel: VBoxContainer = $UI/Control/RightPanel
@onready var sidebar_collapse_button: Button = $UI/Control/RightPanel/SidebarHeader/MarginContainer/HBoxContainer/SidebarCollapseButton
@onready var sidebar_collapse_tab: Button = $UI/Control/SidebarCollapseTab
@onready var metadata_panel: PanelContainer = $UI/Control/RightPanel/MetadataPanel
@onready var metadata_label: RichTextLabel = $UI/Control/RightPanel/MetadataPanel/MarginContainer/VBoxContainer/ContentContainer/ScrollContainer/MetadataLabel
@onready var metadata_collapse_button: Button = $UI/Control/RightPanel/MetadataPanel/MarginContainer/VBoxContainer/HeaderContainer/CollapseButton
@onready var metadata_content: VBoxContainer = $UI/Control/RightPanel/MetadataPanel/MarginContainer/VBoxContainer/ContentContainer
@onready var camera_controller: Camera3D = $Camera3D
@onready var camera_mode_button: Button = $UI/Control/RightPanel/ButtonsPanel/MarginContainer/VBoxContainer/CameraModeButton

func _input(event: InputEvent) -> void:
	# Keyboard hotkeys
	if event is InputEventKey and event.pressed and not event.echo:
		# C for configuration (settings)
		if event.keycode == KEY_C:
			_on_settings_button_pressed()
			get_viewport().set_input_as_handled()
		# L for loading VRM
		elif event.keycode == KEY_L:
			_on_load_model_button_pressed()
			get_viewport().set_input_as_handled()

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
	
	# Connect collapse buttons
	if webcam_collapse_button:
		webcam_collapse_button.pressed.connect(_on_webcam_collapse_pressed)
	if sidebar_collapse_button:
		sidebar_collapse_button.pressed.connect(_on_sidebar_collapse_pressed)
	if sidebar_collapse_tab:
		sidebar_collapse_tab.pressed.connect(_on_sidebar_expand_pressed)
	if metadata_collapse_button:
		metadata_collapse_button.pressed.connect(_on_metadata_collapse_pressed)
	
	# Connect camera mode signal and set model container reference
	if camera_controller:
		camera_controller.mode_changed.connect(_on_camera_mode_changed)
		camera_controller.model_container = model_container
		camera_controller.model_transform_changed.connect(_on_model_transform_changed)
		print("Camera controller set up with model container")
	if camera_mode_button:
		camera_mode_button.pressed.connect(_on_camera_mode_button_pressed)
	
	# Load saved settings and apply
	_load_and_apply_settings()
	
	# Load last used model or default VRM model
	var model_to_load := _get_last_model_path()
	print("Checking for VRM model at: ", model_to_load)
	
	# Android-specific: Check if file exists and log platform info
	if platform_name == "Android":
		print("Android platform detected - VRM file check")
		print("  - File exists: ", FileAccess.file_exists(model_to_load))
		print("  - User data dir: ", OS.get_user_data_dir())
	
	if FileAccess.file_exists(model_to_load):
		print("VRM model found! Loading...")
		call_deferred("_load_vrm_model", model_to_load)
	else:
		print("WARNING: No VRM model found at: ", model_to_load)
		if platform_name == "Android":
			print("Android: The VRM file may not have been included in the APK export.")
			print("Android: Check export_presets.cfg include_filter setting.")
		print("Place a VRM model as 'default.vrm' in the models/ directory for auto-loading")
		# Set info label to show instructions
		if info_label:
			info_label.text = "No model loaded.\nUse 'Load VRM Model' button or press L\nDrag to rotate/pan | Q/E to zoom | R to switch mode"

func _load_and_apply_settings() -> void:
	"""Load settings from file and apply graphics settings"""
	var config := ConfigFile.new()
	var err := config.load("user://vrmvtube_settings.cfg")
	
	if err == OK:
		# Apply graphics settings
		if config.has_section("graphics"):
			var resolution_scale = config.get_value("graphics", "resolution_scale", 1.0)
			get_viewport().scaling_3d_scale = resolution_scale
			
			var msaa = config.get_value("graphics", "msaa", 0)
			get_viewport().msaa_3d = msaa
			
			var vsync_enabled = config.get_value("graphics", "vsync", true)
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED)
			
			print("Applied graphics settings: resolution_scale=", resolution_scale, " msaa=", msaa, " vsync=", vsync_enabled)

func _get_last_model_path() -> String:
	"""Get the last loaded model path from settings, or default"""
	var config := ConfigFile.new()
	var err := config.load("user://vrmvtube_settings.cfg")
	
	if err == OK and config.has_section("model"):
		var last_path = config.get_value("model", "path", DEFAULT_VRM_PATH)
		# Check if the last path exists, otherwise fall back to default
		if FileAccess.file_exists(last_path):
			return last_path
	
	return DEFAULT_VRM_PATH

func _load_model_transform() -> void:
	"""Load and apply saved model transform"""
	var config := ConfigFile.new()
	var err := config.load("user://vrmvtube_settings.cfg")
	
	if err == OK and config.has_section("model") and camera_controller:
		var pos = Vector3(
			config.get_value("model", "position_x", 0.0),
			config.get_value("model", "position_y", -0.5),
			config.get_value("model", "position_z", 0.0)
		)
		var rot = Vector3(
			config.get_value("model", "rotation_x", 0.0),
			config.get_value("model", "rotation_y", 0.0),
			config.get_value("model", "rotation_z", 0.0)
		)
		var scale_val = config.get_value("model", "scale", 1.5)
		
		camera_controller.set_model_transform(pos, rot, scale_val)
		print("Loaded model transform: pos=", pos, " rot=", rot, " scale=", scale_val)
	elif camera_controller:
		# Use defaults if no saved transform
		camera_controller.set_model_transform(Vector3(0, -0.5, 0), Vector3.ZERO, 1.5)
		print("Using default model transform")

func _save_last_model(path: String) -> void:
	"""Save the last loaded model path and transform"""
	var config := ConfigFile.new()
	config.load("user://vrmvtube_settings.cfg")  # Load existing settings
	config.set_value("model", "path", path)
	
	# Save current model transform if camera controller has it
	if camera_controller:
		var transform_data = camera_controller.get_model_transform()
		config.set_value("model", "position_x", transform_data.position.x)
		config.set_value("model", "position_y", transform_data.position.y)
		config.set_value("model", "position_z", transform_data.position.z)
		config.set_value("model", "rotation_x", transform_data.rotation.x)
		config.set_value("model", "rotation_y", transform_data.rotation.y)
		config.set_value("model", "rotation_z", transform_data.rotation.z)
		config.set_value("model", "scale", transform_data.scale)
	
	config.save("user://vrmvtube_settings.cfg")
	print("Saved last model path and transform")

func _on_model_transform_changed(position: Vector3, rotation: Vector3, scale_factor: float) -> void:
	"""Auto-save model transform when it changes"""
	_save_last_model(_get_last_model_path())

func _on_camera_mode_changed(is_pan_mode: bool) -> void:
	"""Update UI when camera mode changes"""
	if camera_mode_button:
		camera_mode_button.text = "Mode: PAN (R)" if is_pan_mode else "Mode: ROTATE (R)"
	
	# Update info label with current mode
	var mode_text = "PAN" if is_pan_mode else "ROTATE"
	print("Camera mode changed to: ", mode_text)

func _on_camera_mode_button_pressed() -> void:
	"""Toggle camera mode when button is pressed"""
	if camera_controller:
		camera_controller.toggle_pan_mode()

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
	var file_dialog = $FileDialog
	
	# Android scoped storage - use external app data directory
	if OS.get_name() == "Android":
		# Get external storage using Android API
		var app_data_path = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
		
		# Check if we got a valid external storage path
		if app_data_path.is_empty() or app_data_path.begins_with("/data/data/"):
			# Try getting the external storage directory and construct app path
			var external_storage = OS.get_environment("EXTERNAL_STORAGE")
			if not external_storage.is_empty():
				app_data_path = external_storage + "/Android/data/com.vrmvtube.app/files"
			else:
				# Last resort: use user data dir (may not be user-accessible)
				app_data_path = OS.get_user_data_dir()
		
		file_dialog.current_dir = app_data_path
		file_dialog.current_path = app_data_path
		print("Android: File picker set to: ", app_data_path)
	
	file_dialog.popup_centered()

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
	
	# Remove previous model if exists - IMMEDIATE removal
	if current_vrm_instance != null:
		print("Removing previous VRM model...")
		# Remove from scene tree immediately
		model_container.remove_child(current_vrm_instance)
		# Free the node
		current_vrm_instance.queue_free()
		current_vrm_instance = null
		# Wait for cleanup to complete
		await get_tree().process_frame
	
	# Load VRM model - handle both res:// and external paths
	var loaded_scene: Node = null
	
	if path.begins_with("res://"):
		# Internal resource - use standard load
		var packed_scene = load(path)
		if packed_scene != null:
			loaded_scene = packed_scene.instantiate()
	else:
		# External file - use runtime GLTF/VRM loading
		loaded_scene = _load_vrm_runtime(path)
	
	if loaded_scene != null:
		current_vrm_instance = loaded_scene
		model_container.add_child(current_vrm_instance)
		
		# DON'T set position/scale here - let camera controller handle it
		# This prevents overriding saved transforms
		if current_vrm_instance is Node3D:
			# Reset to origin - camera controller will apply saved transform
			current_vrm_instance.position = Vector3.ZERO
			current_vrm_instance.rotation = Vector3.ZERO
			current_vrm_instance.scale = Vector3.ONE
		
		# Load and apply saved model transform
		_load_model_transform()
		
		# IMPORTANT: Ensure materials and textures are preserved
		# Wait for the scene tree to fully process the node
		await get_tree().process_frame
		await get_tree().process_frame  # Extra frame wait for material loading
		
		# Check materials but DON'T duplicate - just verify
		print("Checking VRM materials...")
		_update_vrm_materials(current_vrm_instance)
		
		# Wait one more frame after material check
		await get_tree().process_frame
		
		# Connect model to face rigging
		if face_rigging:
			face_rigging.set_vrm_model(current_vrm_instance)
		
		# Extract and display metadata
		_update_metadata_display(current_vrm_instance)
		
		print("VRM model loaded successfully")
		info_label.text = "VRM model loaded: " + path.get_file() + "\nDrag to rotate/pan | Q/E zoom | R mode | WASD move | C config | L load"
		
		# Save last loaded model
		_save_last_model(path)
		
		# Show model controls and metadata
		if model_controls_panel:
			model_controls_panel.visible = true
		if metadata_panel:
			metadata_panel.visible = true
	else:
		var error_msg := "Failed to load VRM model"
		push_error(error_msg)
		info_label.text = "Error: " + error_msg

func _on_reset_pose_button_pressed() -> void:
	"""Reset model to default position, rotation, and scale"""
	if camera_controller:
		camera_controller.set_model_transform(Vector3(0, -0.5, 0), Vector3.ZERO, 1.5)
		
		# Reset sliders to match default values
		if position_y_slider:
			position_y_slider.value = -0.5
		if scale_slider:
			scale_slider.value = 1.5

func _on_position_y_changed(value: float) -> void:
	"""Update model Y position via camera controller"""
	if camera_controller:
		var transform_data = camera_controller.get_model_transform()
		transform_data.position.y = value
		camera_controller.set_model_transform(transform_data.position, transform_data.rotation, transform_data.scale)
	if position_y_value:
		position_y_value.text = "%.2f" % value

func _on_scale_changed(value: float) -> void:
	"""Update model scale via camera controller"""
	if camera_controller:
		var transform_data = camera_controller.get_model_transform()
		camera_controller.set_model_transform(transform_data.position, transform_data.rotation, value)
	if scale_value:
		scale_value.text = "%.2f" % value

func _update_vrm_materials(node: Node) -> void:
	"""Recursively update materials on VRM model - DO NOT duplicate to prevent white flash"""
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh:
			print("Checking materials for mesh: ", node.name)
			# DON'T duplicate materials - this causes the white flash!
			# Just ensure the materials are properly visible
			for i in range(mesh_instance.mesh.get_surface_count()):
				var material := mesh_instance.mesh.surface_get_material(i)
				if material:
					# Only modify transparency/visibility if needed, without duplicating
					if material is StandardMaterial3D:
						var std_mat := material as StandardMaterial3D
						# Only fix if actually transparent
						if std_mat.albedo_color.a < 0.99:
							std_mat.albedo_color.a = 1.0
							print("  - Fixed transparency on surface ", i)
					elif material is ShaderMaterial:
						# For MToon shader, only check critical transparency params
						var shader_mat := material as ShaderMaterial
						# Don't reset shader or duplicate - just leave it as loaded
						print("  - Shader material on surface ", i, " - keeping as-is")
					
					print("  - Surface ", i, " material: ", material.get_class())
	
	# Recursively process children
	for child in node.get_children():
		_update_vrm_materials(child)

func _load_vrm_runtime(path: String) -> Node:
	"""Load VRM file at runtime using GLTFDocument (for external files)"""
	print("Runtime VRM loading from: ", path)
	
	# Create GLTF document and state
	var gltf := GLTFDocument.new()
	var state := GLTFState.new()
	
	# Register VRM extension for proper VRM support
	const vrm_extension_script = preload("res://addons/vrm/vrm_extension.gd")
	var vrm_extension: GLTFDocumentExtension = vrm_extension_script.new()
	gltf.register_gltf_document_extension(vrm_extension, true)
	
	# Configure state for VRM loading
	state.handle_binary_image = GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED
	
	# Load the VRM file
	var error := gltf.append_from_file(path, state, 0)
	if error != OK:
		push_error("Failed to parse VRM file: " + str(error))
		gltf.unregister_gltf_document_extension(vrm_extension)
		return null
	
	# Generate the scene
	var generated_scene := gltf.generate_scene(state)
	gltf.unregister_gltf_document_extension(vrm_extension)
	
	if generated_scene == null:
		push_error("Failed to generate scene from VRM file")
		return null
	
	print("VRM runtime loading successful")
	return generated_scene

func _on_settings_button_pressed() -> void:
	"""Open settings menu"""
	if settings_menu:
		settings_menu.show_settings()

func _on_settings_applied(settings: Dictionary) -> void:
	"""Apply settings from settings menu"""
	print("Settings applied: ", settings)
	
	# Apply model settings
	if settings.has("model") and settings.model.has("path"):
		var model_path: String = settings.model.path
		if model_path != "" and model_path != DEFAULT_VRM_PATH:
			if current_vrm_instance == null or model_path != current_vrm_instance.get("vrm_path"):
				_load_vrm_model(model_path)
	
	# Apply background settings
	if settings.has("background"):
		_apply_background_settings(settings.background)
	
	# Apply graphics settings
	if settings.has("graphics"):
		_apply_graphics_settings(settings.graphics)
	
	# Camera settings are handled by webcam_tracker

func _apply_graphics_settings(graphics_settings: Dictionary) -> void:
	"""Apply graphics quality settings"""
	if graphics_settings.has("resolution_scale"):
		get_viewport().scaling_3d_scale = graphics_settings.resolution_scale
		print("Applied resolution scale: ", graphics_settings.resolution_scale)
	
	if graphics_settings.has("msaa"):
		get_viewport().msaa_3d = graphics_settings.msaa
		print("Applied MSAA: ", graphics_settings.msaa)
	
	if graphics_settings.has("vsync"):
		var mode = DisplayServer.VSYNC_ENABLED if graphics_settings.vsync else DisplayServer.VSYNC_DISABLED
		DisplayServer.window_set_vsync_mode(mode)
		print("Applied VSync: ", graphics_settings.vsync)

func _apply_background_settings(bg_settings: Dictionary) -> void:
	"""Apply background color/type settings"""
	if not world_environment or not world_environment.environment:
		return
	
	var env := world_environment.environment
	
	match bg_settings.get("type", "solid"):
		"solid":
			env.background_mode = Environment.BG_COLOR
			if bg_settings.has("color"):
				env.background_color = bg_settings.color
		"gradient":
			# Godot doesn't have built-in gradient background
			# Use solid color for now (could implement custom sky shader)
			env.background_mode = Environment.BG_COLOR
			if bg_settings.has("gradient_top"):
				env.background_color = bg_settings.gradient_top
		"image":
			if bg_settings.has("image_path") and bg_settings.image_path != "":
				# Would need to load image and set as sky
				# For now, keep current background
				pass

func _on_webcam_collapse_pressed() -> void:
	"""Toggle webcam preview panel collapse"""
	if webcam_content:
		webcam_content.visible = not webcam_content.visible
		if webcam_collapse_button:
			webcam_collapse_button.text = "▲" if not webcam_content.visible else "▼"

func _on_sidebar_collapse_pressed() -> void:
	"""Collapse the entire sidebar"""
	sidebar_collapsed = true
	if right_panel:
		right_panel.visible = false
	if sidebar_collapse_tab:
		sidebar_collapse_tab.visible = true
	print("Sidebar collapsed")

func _on_sidebar_expand_pressed() -> void:
	"""Expand the sidebar"""
	sidebar_collapsed = false
	if right_panel:
		right_panel.visible = true
	if sidebar_collapse_tab:
		sidebar_collapse_tab.visible = false
	print("Sidebar expanded")

func _on_metadata_collapse_pressed() -> void:
	"""Toggle metadata panel collapse"""
	if metadata_content:
		metadata_content.visible = not metadata_content.visible
		if metadata_collapse_button:
			metadata_collapse_button.text = "▲" if not metadata_content.visible else "▼"

func _update_metadata_display(vrm_node: Node) -> void:
	"""Extract and display VRM metadata"""
	if not metadata_label:
		return
	
	# Find VRM metadata node
	var vrm_meta = null
	for child in vrm_node.get_children():
		if child.has_meta("vrm_meta"):
			vrm_meta = child.get_meta("vrm_meta")
			break
		# Also check if the child itself has vrm_meta property
		if "vrm_meta" in child:
			vrm_meta = child.vrm_meta
			break
	
	# Try to find in the root node as well
	if vrm_meta == null and vrm_node.has_meta("vrm_meta"):
		vrm_meta = vrm_node.get_meta("vrm_meta")
	if vrm_meta == null and "vrm_meta" in vrm_node:
		vrm_meta = vrm_node.vrm_meta
	
	# Build metadata display
	var metadata_text := ""
	
	if vrm_meta:
		metadata_text += "[b]VRM Metadata[/b]\n\n"
		
		# Basic info
		if vrm_meta.get("title"):
			metadata_text += "[b]Title:[/b] " + str(vrm_meta.title) + "\n"
		if vrm_meta.get("version"):
			metadata_text += "[b]Version:[/b] " + str(vrm_meta.version) + "\n"
		if vrm_meta.get("authors") and vrm_meta.authors.size() > 0:
			metadata_text += "[b]Author:[/b] " + ", ".join(vrm_meta.authors) + "\n"
		elif vrm_meta.get("author"):
			metadata_text += "[b]Author:[/b] " + str(vrm_meta.author) + "\n"
		
		# Contact and reference
		if vrm_meta.get("contact_information"):
			metadata_text += "[b]Contact:[/b] " + str(vrm_meta.contact_information) + "\n"
		if vrm_meta.get("references") and vrm_meta.references.size() > 0:
			metadata_text += "[b]References:[/b] " + ", ".join(vrm_meta.references) + "\n"
		
		metadata_text += "\n[b]Permissions:[/b]\n"
		
		# Usage permissions
		if vrm_meta.get("allowed_user_name") and vrm_meta.allowed_user_name != " ":
			metadata_text += "• User: " + str(vrm_meta.allowed_user_name) + "\n"
		if vrm_meta.get("commercial_usage_type") and vrm_meta.commercial_usage_type != " ":
			metadata_text += "• Commercial: " + str(vrm_meta.commercial_usage_type) + "\n"
		if vrm_meta.get("violent_usage") and vrm_meta.violent_usage != " ":
			metadata_text += "• Violent Content: " + str(vrm_meta.violent_usage) + "\n"
		if vrm_meta.get("sexual_usage") and vrm_meta.sexual_usage != " ":
			metadata_text += "• Sexual Content: " + str(vrm_meta.sexual_usage) + "\n"
		if vrm_meta.get("credit_notation") and vrm_meta.credit_notation != " ":
			metadata_text += "• Credit: " + str(vrm_meta.credit_notation) + "\n"
		if vrm_meta.get("modification") and vrm_meta.modification != " ":
			metadata_text += "• Modification: " + str(vrm_meta.modification) + "\n"
		if vrm_meta.get("allow_redistribution") and vrm_meta.allow_redistribution != " ":
			metadata_text += "• Redistribution: " + str(vrm_meta.allow_redistribution) + "\n"
		
		# License info
		metadata_text += "\n[b]License:[/b]\n"
		if vrm_meta.get("license_name"):
			metadata_text += "• " + str(vrm_meta.license_name) + "\n"
		if vrm_meta.get("license_url"):
			metadata_text += "• URL: " + str(vrm_meta.license_url) + "\n"
		if vrm_meta.get("other_license_url"):
			metadata_text += "• Other: " + str(vrm_meta.other_license_url) + "\n"
		
		# Technical info
		metadata_text += "\n[b]Technical Info:[/b]\n"
		if vrm_meta.get("spec_version"):
			metadata_text += "• VRM Spec: " + str(vrm_meta.spec_version) + "\n"
		if vrm_meta.get("exporter_version"):
			metadata_text += "• Exporter: " + str(vrm_meta.exporter_version) + "\n"
	else:
		metadata_text = "[b]Model Metadata[/b]\n\nNo VRM metadata found in this model.\n\nThis may be because:\n• Model is not a standard VRM file\n• Metadata was not included by the creator\n• Model was exported without metadata"
	
	metadata_label.text = metadata_text
	print("Metadata display updated")
