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
	
	# Load default VRM model - use call_deferred to ensure scene is ready
	print("Checking for default VRM model at: ", DEFAULT_VRM_PATH)
	
	# Android-specific: Check if file exists and log platform info
	if platform_name == "Android":
		print("Android platform detected - VRM file check")
		print("  - File exists: ", FileAccess.file_exists(DEFAULT_VRM_PATH))
		print("  - User data dir: ", OS.get_user_data_dir())
	
	if FileAccess.file_exists(DEFAULT_VRM_PATH):
		print("Default VRM model found! Loading...")
		call_deferred("_load_vrm_model", DEFAULT_VRM_PATH)
	else:
		print("WARNING: No default VRM model found at: ", DEFAULT_VRM_PATH)
		if platform_name == "Android":
			print("Android: The VRM file may not have been included in the APK export.")
			print("Android: Check export_presets.cfg include_filter setting.")
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
		
		# Position the model in the container - centered and scaled appropriately
		if current_vrm_instance is Node3D:
			current_vrm_instance.position = Vector3(0, -0.5, 0)  # Lower position for better centering
			# Scale larger for better visibility (1.5x default)
			current_vrm_instance.scale = Vector3(1.5, 1.5, 1.5)
		
		# IMPORTANT: Ensure materials and textures are preserved
		# Wait for the scene tree to fully process the node
		await get_tree().process_frame
		await get_tree().process_frame  # Extra frame wait for material loading
		
		# Force material update on all meshes
		print("Updating VRM materials...")
		_update_vrm_materials(current_vrm_instance)
		
		# Wait one more frame after material update
		await get_tree().process_frame
		
		# Connect model to face rigging
		if face_rigging:
			face_rigging.set_vrm_model(current_vrm_instance)
		
		# Extract and display metadata
		_update_metadata_display(current_vrm_instance)
		
		print("VRM model loaded successfully")
		info_label.text = "VRM model loaded: " + path.get_file() + "\nControls: Drag to rotate | Shift+Drag to pan | Scroll to zoom"
		
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
	"""Reset model to default position and scale"""
	if current_vrm_instance and current_vrm_instance is Node3D:
		current_vrm_instance.position = Vector3(0, -0.5, 0)
		current_vrm_instance.scale = Vector3(1.5, 1.5, 1.5)
		current_vrm_instance.rotation = Vector3(0, 0, 0)
		
		# Reset sliders to match default values
		if position_y_slider:
			position_y_slider.value = -0.5
		if scale_slider:
			scale_slider.value = 1.5

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

func _update_vrm_materials(node: Node) -> void:
	"""Recursively update materials on VRM model to ensure textures and shaders load properly"""
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh:
			print("Updating materials for mesh: ", node.name)
			# Force material update on all surfaces
			for i in range(mesh_instance.mesh.get_surface_count()):
				var material := mesh_instance.mesh.surface_get_material(i)
				if material:
					# Strategy 1: Duplicate the material to force a refresh
					# This ensures shader and textures are properly loaded
					var duplicated_material := material.duplicate(true)  # Deep duplicate
					
					# Strategy 2: Force visibility and transparency settings
					if duplicated_material is StandardMaterial3D:
						# For standard materials, ensure flags are set correctly
						var std_mat := duplicated_material as StandardMaterial3D
						std_mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
						std_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
						std_mat.vertex_color_use_as_albedo = false
						# Ensure albedo is visible
						if std_mat.albedo_color.a < 1.0:
							std_mat.albedo_color.a = 1.0
					elif duplicated_material is ShaderMaterial:
						# For shader materials (like MToon), force parameter refresh
						var shader_mat := duplicated_material as ShaderMaterial
						if shader_mat.shader:
							print("  - Shader material found: ", shader_mat.shader.resource_path if shader_mat.shader.resource_path else "inline shader")
							
							# For MToon shader, ensure alpha/transparency is set correctly
							# Check for common transparency parameters
							var param_names := ["_alpha", "alpha", "_Alpha", "transparency", "_Cutoff"]
							for param in param_names:
								if shader_mat.get_shader_parameter(param) != null:
									var current_val = shader_mat.get_shader_parameter(param)
									# If alpha/transparency exists, ensure it's visible
									if current_val is float and current_val < 0.9:
										shader_mat.set_shader_parameter(param, 1.0)
										print("  - Set ", param, " to 1.0 (was ", current_val, ")")
							
							# Force shader refresh
							var current_shader := shader_mat.shader
							shader_mat.shader = null
							shader_mat.shader = current_shader
					
					# Strategy 3: Apply the duplicated material as override
					mesh_instance.set_surface_override_material(i, duplicated_material)
					
					# Strategy 4: Also set it on the mesh directly as fallback
					mesh_instance.mesh.surface_set_material(i, duplicated_material)
					
					print("  - Surface ", i, " material updated: ", material.get_class())
	
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
	
	# Camera settings are handled by webcam_tracker

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
