extends Node3D

## Main scene controller for VRMVTube
## 
## This script handles loading VRM models and basic scene setup.
## Based on V-Sekai's implementation and inspired by VRigUnity.
##
## Credits:
## - VRM loading powered by godot-vrm (MIT License, V-Sekai)
## - Inspired by VRigUnity by Kariaro

const DEFAULT_VRM_PATH := "res://models/default.vrm"

var current_vrm_instance: Node = null

func _ready() -> void:
	print("VRMVTube started")
	print("Platform: ", OS.get_name())
	
	# Check virtual camera support
	if OS.get_name() in ["Windows", "Linux", "X11"]:
		print("Virtual camera is supported on this platform")
	else:
		print("Virtual camera is NOT supported on this platform")
	
	# Try to load default VRM model if it exists
	if FileAccess.file_exists(DEFAULT_VRM_PATH):
		print("Loading default VRM model...")
		_load_vrm_model(DEFAULT_VRM_PATH)
	else:
		print("No default VRM model found at: ", DEFAULT_VRM_PATH)
		print("Place a VRM model as 'default.vrm' in the models/ directory for auto-loading")

func _on_load_model_button_pressed() -> void:
	"""Show file dialog to select VRM model"""
	$FileDialog.popup_centered()

func _on_file_selected(path: String) -> void:
	"""Load the selected VRM model"""
	_load_vrm_model(path)

func _load_vrm_model(path: String) -> void:
	"""Internal function to load a VRM model from path"""
	print("Loading VRM model from: ", path)
	
	if not FileAccess.file_exists(path):
		push_error("VRM file not found: " + path)
		return
	
	# Remove previous model if exists
	if current_vrm_instance != null:
		current_vrm_instance.queue_free()
		current_vrm_instance = null
	
	# Load VRM model
	# Note: The actual VRM loading will use godot-vrm's VRMTopLevel
	# This is a placeholder implementation
	var loaded_scene = load(path)
	if loaded_scene != null:
		current_vrm_instance = loaded_scene.instantiate()
		add_child(current_vrm_instance)
		
		# Position the model
		if current_vrm_instance is Node3D:
			current_vrm_instance.position = Vector3(0, 0, 0)
		
		print("VRM model loaded successfully")
	else:
		push_error("Failed to load VRM model")
