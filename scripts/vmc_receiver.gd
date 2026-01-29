extends Node

## VMC Protocol Receiver for VRMVTube
##
## Receives Virtual Motion Capture (VMC) protocol messages via OSC over UDP
## Compatible with VSeeFace, Virtual Motion Capture, Warudo, and other VMC apps
##
## Default port: 39539 (VMC Marionette/Receiver standard)
##
## Created by: GitHub Copilot

signal bone_transform_received(bone_name: String, position: Vector3, rotation: Quaternion)
signal blendshape_received(name: String, value: float)
signal root_transform_received(position: Vector3, rotation: Quaternion)
signal tracking_data_received(data: Dictionary)
signal vmc_available_changed(available: bool)

const DEFAULT_PORT := 39539
const OSC = preload("res://scripts/osc.gd")

@export var enabled: bool = true
@export var port: int = DEFAULT_PORT

var udp := PacketPeerUDP.new()
var is_bound: bool = false
var last_packet_time: float = 0.0
var total_packets: int = 0

# VMC data storage
var bone_transforms := {}
var blendshapes := {}
var root_position := Vector3.ZERO
var root_rotation := Quaternion.IDENTITY

# Bone name mapping (Unity HumanBodyBones to VRM/Godot)
const BONE_MAP := {
	"Hips": "Hips",
	"Spine": "Spine",
	"Chest": "Chest",
	"Neck": "Neck",
	"Head": "Head",
	"LeftShoulder": "LeftShoulder",
	"LeftUpperArm": "LeftUpperArm",
	"LeftLowerArm": "LeftLowerArm",
	"LeftHand": "LeftHand",
	"RightShoulder": "RightShoulder",
	"RightUpperArm": "RightUpperArm",
	"RightLowerArm": "RightLowerArm",
	"RightHand": "RightHand",
	"LeftUpperLeg": "LeftUpperLeg",
	"LeftLowerLeg": "LeftLowerLeg",
	"LeftFoot": "LeftFoot",
	"RightUpperLeg": "RightUpperLeg",
	"RightLowerLeg": "RightLowerLeg",
	"RightFoot": "RightFoot",
}

func _ready() -> void:
	if enabled:
		_bind_port()

func _bind_port() -> void:
	"""Bind to VMC receiver port"""
	var err := udp.bind(port)
	if err != OK:
		push_error("VMCReceiver: Failed to bind to port %d (error %d)" % [port, err])
		is_bound = false
	else:
		print("VMCReceiver: Listening on port %d for VMC protocol messages" % port)
		print("VMCReceiver: Compatible with VSeeFace, VMC, Warudo, etc.")
		is_bound = true
		vmc_available_changed.emit(true)

func _process(_delta: float) -> void:
	if not is_bound or not enabled:
		return
	
	# Process all available packets
	var packets_processed := 0
	while udp.get_available_packet_count() > 0 and packets_processed < 100:
		var packet := udp.get_packet()
		_process_osc_packet(packet)
		packets_processed += 1

func _process_osc_packet(packet: PackedByteArray) -> void:
	"""Process a single OSC packet (VMC message)"""
	var message := OSC.unpack_message(packet)
	
	if message.address == "":
		return
	
	total_packets += 1
	last_packet_time = Time.get_ticks_msec() / 1000.0
	
	# Route message based on address
	match message.address:
		"/VMC/Ext/Root/Pos":
			_handle_root_pos(message.args)
		
		"/VMC/Ext/Bone/Pos":
			_handle_bone_pos(message.args)
		
		"/VMC/Ext/Blend/Val":
			_handle_blend_val(message.args)
		
		"/VMC/Ext/Blend/Apply":
			_handle_blend_apply()
		
		"/VMC/Ext/OK":
			_handle_ok(message.args)
		
		"/VMC/Ext/T":
			_handle_time(message.args)
		
		_:
			# Unknown message - ignore for forward compatibility
			pass

func _handle_root_pos(args: Array) -> void:
	"""Handle /VMC/Ext/Root/Pos message
	Args: (string)name (float)px py pz (float)qx qy qz qw"""
	if args.size() < 8:
		return
	
	# args[0] = name (usually "root")
	root_position = Vector3(args[1], args[2], args[3])
	root_rotation = Quaternion(args[4], args[5], args[6], args[7])
	
	root_transform_received.emit(root_position, root_rotation)

func _handle_bone_pos(args: Array) -> void:
	"""Handle /VMC/Ext/Bone/Pos message
	Args: (string)boneName (float)px py pz (float)qx qy qz qw"""
	if args.size() < 8:
		return
	
	var bone_name: String = args[0]
	var position := Vector3(args[1], args[2], args[3])
	var rotation := Quaternion(args[4], args[5], args[6], args[7])
	
	# Store transform
	bone_transforms[bone_name] = {
		"position": position,
		"rotation": rotation
	}
	
	bone_transform_received.emit(bone_name, position, rotation)

func _handle_blend_val(args: Array) -> void:
	"""Handle /VMC/Ext/Blend/Val message
	Args: (string)blendShapeName (float)value"""
	if args.size() < 2:
		return
	
	var blend_name: String = args[0]
	var value: float = args[1]
	
	# Store blendshape value
	blendshapes[blend_name] = value
	
	blendshape_received.emit(blend_name, value)

func _handle_blend_apply() -> void:
	"""Handle /VMC/Ext/Blend/Apply message
	Signals that all blendshape values should be applied now"""
	# Convert blendshapes to tracking data format
	var tracking_data := _convert_to_tracking_data()
	tracking_data_received.emit(tracking_data)

func _handle_ok(args: Array) -> void:
	"""Handle /VMC/Ext/OK message
	Args: (int)loaded [calibration state] [calibration mode] [tracking status]"""
	# This indicates the sender is ready
	# args[0] = loaded (1 if loaded, 0 if not)
	pass

func _handle_time(args: Array) -> void:
	"""Handle /VMC/Ext/T message
	Args: (float)time"""
	# Timestamp from sender
	pass

func _convert_to_tracking_data() -> Dictionary:
	"""Convert VMC blendshapes to tracking data format"""
	# Map VMC/VRM blendshapes to our tracking format
	var tracking_data := {
		"blink_left": blendshapes.get("BlinkLeft", blendshapes.get("Blink_L", 0.0)),
		"blink_right": blendshapes.get("BlinkRight", blendshapes.get("Blink_R", 0.0)),
		"mouth_open": blendshapes.get("A", blendshapes.get("aa", 0.0)),
		"smile": blendshapes.get("Joy", blendshapes.get("joy", 0.0)),
		"head_rotation": Vector3.ZERO,  # Would come from bone data
		"head_position": Vector3.ZERO,
		"tracking_quality": 1.0,
		"source": "vmc"
	}
	
	# Get head rotation from bone data if available
	if bone_transforms.has("Head"):
		var head_transform = bone_transforms["Head"]
		var euler := head_transform.rotation.get_euler()
		tracking_data.head_rotation = euler
	
	return tracking_data

func get_bone_transform(bone_name: String) -> Dictionary:
	"""Get transform for a specific bone"""
	return bone_transforms.get(bone_name, {})

func get_blendshape_value(name: String) -> float:
	"""Get value for a specific blendshape"""
	return blendshapes.get(name, 0.0)

func get_all_blendshapes() -> Dictionary:
	"""Get all current blendshape values"""
	return blendshapes.duplicate()

func get_all_bones() -> Dictionary:
	"""Get all current bone transforms"""
	return bone_transforms.duplicate()

func get_status() -> Dictionary:
	"""Get receiver status information"""
	var current_time := Time.get_ticks_msec() / 1000.0
	var time_since_packet := current_time - last_packet_time
	
	return {
		"is_bound": is_bound,
		"port": port,
		"enabled": enabled,
		"total_packets": total_packets,
		"time_since_last_packet": time_since_packet,
		"is_receiving": time_since_packet < 1.0,
		"bone_count": bone_transforms.size(),
		"blendshape_count": blendshapes.size()
	}

func set_enabled(value: bool) -> void:
	"""Enable or disable VMC receiver"""
	enabled = value
	if enabled and not is_bound:
		_bind_port()
	elif not enabled:
		vmc_available_changed.emit(false)

func _exit_tree() -> void:
	"""Cleanup when node is removed"""
	udp.close()
	print("VMCReceiver: Closed")
