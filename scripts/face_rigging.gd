extends Node

## Face Rigging Controller for VRMVTube
##
## Applies face tracking data to VRM model blend shapes
## Works with all platforms that have webcam access
##
## Created by: GitHub Copilot
## Platform Support: All platforms (Windows, macOS, Linux, Android, Web)

@export var vrm_model: Node3D
@export var smoothing_factor: float = 0.3

# VRM blend shape names (standard VRM expressions)
const BLEND_SHAPES := {
	"blink_left": "blinkLeft",
	"blink_right": "blinkRight",
	"blink": "blink",
	"mouth_open": "aa",
	"mouth_smile": "joy",
	"mouth_sad": "sorrow",
	"mouth_funnel": "oh",
	"brow_angry": "angry",
	"brow_surprised": "surprised",
	"neutral": "neutral"
}

# Current blend shape values
var current_blend_shapes := {}
var target_blend_shapes := {}

# Head tracking
var current_head_rotation := Vector3.ZERO
var target_head_rotation := Vector3.ZERO

func _ready() -> void:
	# Initialize blend shape values
	for key in BLEND_SHAPES.keys():
		current_blend_shapes[key] = 0.0
		target_blend_shapes[key] = 0.0

func apply_tracking_data(tracking_data: Dictionary) -> void:
	"""Apply face tracking data to VRM model"""
	if not vrm_model:
		return
	
	# Update target values from tracking data
	if tracking_data.has("blink_left"):
		target_blend_shapes["blink_left"] = tracking_data["blink_left"]
	
	if tracking_data.has("blink_right"):
		target_blend_shapes["blink_right"] = tracking_data["blink_right"]
	
	if tracking_data.has("mouth_open"):
		target_blend_shapes["mouth_open"] = tracking_data["mouth_open"]
	
	if tracking_data.has("smile"):
		target_blend_shapes["mouth_smile"] = tracking_data["smile"]
	
	if tracking_data.has("head_rotation"):
		target_head_rotation = tracking_data["head_rotation"]

func _process(delta: float) -> void:
	if not vrm_model:
		return
	
	# Smooth blend shape transitions
	for key in current_blend_shapes.keys():
		current_blend_shapes[key] = lerp(
			current_blend_shapes[key],
			target_blend_shapes[key],
			smoothing_factor
		)
	
	# Smooth head rotation
	current_head_rotation = current_head_rotation.lerp(
		target_head_rotation,
		smoothing_factor
	)
	
	# Apply to VRM model
	_apply_blend_shapes()
	_apply_head_rotation()

func _apply_blend_shapes() -> void:
	"""Apply blend shape values to the VRM model"""
	# Find the mesh with blend shapes
	var mesh_instance := _find_mesh_instance(vrm_model)
	if not mesh_instance:
		return
	
	var mesh := mesh_instance.mesh
	if not mesh:
		return
	
	# Apply each blend shape
	for key in current_blend_shapes.keys():
		var vrm_name: String = BLEND_SHAPES.get(key, "")
		if vrm_name.is_empty():
			continue
		
		var value: float = current_blend_shapes[key]
		
		# Try to find and set the blend shape
		var blend_shape_idx: int = mesh.find_blend_shape_by_name(vrm_name)
		if blend_shape_idx >= 0:
			mesh_instance.set_blend_shape_value(blend_shape_idx, value)

func _apply_head_rotation() -> void:
	"""Apply head rotation to appropriate bones"""
	# Find the head bone
	var skeleton := _find_skeleton(vrm_model)
	if not skeleton:
		return
	
	# Find head bone (usually named "Head" or "head")
	var head_bone_idx := skeleton.find_bone("Head")
	if head_bone_idx < 0:
		head_bone_idx = skeleton.find_bone("head")
	
	if head_bone_idx >= 0:
		var current_pose := skeleton.get_bone_pose_rotation(head_bone_idx)
		var target_quat := Quaternion.from_euler(current_head_rotation)
		var blended := current_pose.slerp(target_quat, smoothing_factor)
		skeleton.set_bone_pose_rotation(head_bone_idx, blended)

func _find_mesh_instance(node: Node) -> MeshInstance3D:
	"""Recursively find MeshInstance3D in the node tree"""
	if node is MeshInstance3D:
		return node as MeshInstance3D
	
	for child in node.get_children():
		var result := _find_mesh_instance(child)
		if result:
			return result
	
	return null

func _find_skeleton(node: Node) -> Skeleton3D:
	"""Recursively find Skeleton3D in the node tree"""
	if node is Skeleton3D:
		return node as Skeleton3D
	
	for child in node.get_children():
		var result := _find_skeleton(child)
		if result:
			return result
	
	return null

func set_vrm_model(model: Node3D) -> void:
	"""Set the VRM model to apply rigging to"""
	vrm_model = model
	print("FaceRigging: VRM model set")
	
	# Debug: Print available blend shapes
	var mesh_instance := _find_mesh_instance(vrm_model)
	if mesh_instance and mesh_instance.mesh:
		print("FaceRigging: Mesh has ", mesh_instance.mesh.get_blend_shape_count(), " blend shapes")
		for i in range(mesh_instance.mesh.get_blend_shape_count()):
			print("  - ", mesh_instance.mesh.get_blend_shape_name(i))
