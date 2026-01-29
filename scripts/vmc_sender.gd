extends Node

## VMC Protocol Sender for VRMVTube
##
## Sends Virtual Motion Capture (VMC) protocol messages via OSC over UDP
## Allows other VMC-compatible apps to receive tracking from VRMVTube
##
## Default port: 39540 (VMC Performer/Assistant standard)
##
## Created by: GitHub Copilot

const OSC = preload("res://scripts/osc.gd")

@export var enabled: bool = false
@export var target_ip: String = "127.0.0.1"
@export var target_port: int = 39540
@export var send_fps: int = 60

var udp := PacketPeerUDP.new()
var send_timer: float = 0.0
var frame_time: float = 1.0 / 60.0
var total_sent: int = 0

# Current model state
var root_position := Vector3.ZERO
var root_rotation := Quaternion.IDENTITY
var bone_transforms := {}
var blendshapes := {}

func _ready() -> void:
	frame_time = 1.0 / send_fps
	print("VMCSender: Ready to send to %s:%d at %d FPS" % [target_ip, target_port, send_fps])

func _process(delta: float) -> void:
	if not enabled:
		return
	
	send_timer += delta
	if send_timer >= frame_time:
		send_timer = 0.0
		_send_frame()

func _send_frame() -> void:
	"""Send a complete frame of VMC data"""
	# Send time
	send_time(Time.get_ticks_msec() / 1000.0)
	
	# Send root transform
	send_root_transform(root_position, root_rotation)
	
	# Send all bone transforms
	for bone_name in bone_transforms:
		var transform = bone_transforms[bone_name]
		send_bone_transform(
			bone_name,
			transform.get("position", Vector3.ZERO),
			transform.get("rotation", Quaternion.IDENTITY)
		)
	
	# Send all blendshapes
	for blend_name in blendshapes:
		send_blendshape(blend_name, blendshapes[blend_name])
	
	# Signal blendshapes should be applied
	send_blend_apply()
	
	# Send OK status
	send_ok(1)  # 1 = loaded

func send_time(time: float) -> void:
	"""Send /VMC/Ext/T message"""
	_send_message("/VMC/Ext/T", [time])

func send_ok(loaded: int) -> void:
	"""Send /VMC/Ext/OK message"""
	_send_message("/VMC/Ext/OK", [loaded])

func send_root_transform(position: Vector3, rotation: Quaternion) -> void:
	"""Send /VMC/Ext/Root/Pos message"""
	root_position = position
	root_rotation = rotation
	
	_send_message("/VMC/Ext/Root/Pos", [
		"root",
		position.x, position.y, position.z,
		rotation.x, rotation.y, rotation.z, rotation.w
	])

func send_bone_transform(bone_name: String, position: Vector3, rotation: Quaternion) -> void:
	"""Send /VMC/Ext/Bone/Pos message"""
	bone_transforms[bone_name] = {
		"position": position,
		"rotation": rotation
	}
	
	_send_message("/VMC/Ext/Bone/Pos", [
		bone_name,
		position.x, position.y, position.z,
		rotation.x, rotation.y, rotation.z, rotation.w
	])

func send_blendshape(name: String, value: float) -> void:
	"""Send /VMC/Ext/Blend/Val message"""
	blendshapes[name] = value
	_send_message("/VMC/Ext/Blend/Val", [name, value])

func send_blend_apply() -> void:
	"""Send /VMC/Ext/Blend/Apply message"""
	_send_message("/VMC/Ext/Blend/Apply", [])

func update_from_tracking_data(data: Dictionary) -> void:
	"""Update blendshapes from tracking data and send"""
	# Map tracking data to VRM blendshapes
	if data.has("blink_left"):
		send_blendshape("BlinkLeft", data.blink_left)
	
	if data.has("blink_right"):
		send_blendshape("BlinkRight", data.blink_right)
	
	if data.has("mouth_open"):
		send_blendshape("A", data.mouth_open)
	
	if data.has("smile"):
		send_blendshape("Joy", data.smile)

func update_from_skeleton(skeleton: Skeleton3D) -> void:
	"""Update bone transforms from a Skeleton3D and send"""
	if not skeleton:
		return
	
	# Send transforms for all bones
	for bone_idx in range(skeleton.get_bone_count()):
		var bone_name := skeleton.get_bone_name(bone_idx)
		var bone_pose := skeleton.get_bone_global_pose(bone_idx)
		
		send_bone_transform(
			bone_name,
			bone_pose.origin,
			bone_pose.basis.get_rotation_quaternion()
		)

func _send_message(address: String, args: Array) -> void:
	"""Send an OSC message via UDP"""
	var packet := OSC.pack_message(address, args)
	
	if udp.set_dest_address(target_ip, target_port) == OK:
		var err := udp.put_packet(packet)
		if err == OK:
			total_sent += 1
		else:
			push_warning("VMCSender: Failed to send packet: %d" % err)
	else:
		push_error("VMCSender: Failed to set destination %s:%d" % [target_ip, target_port])

func get_status() -> Dictionary:
	"""Get sender status information"""
	return {
		"enabled": enabled,
		"target_ip": target_ip,
		"target_port": target_port,
		"send_fps": send_fps,
		"total_sent": total_sent,
		"bone_count": bone_transforms.size(),
		"blendshape_count": blendshapes.size()
	}

func set_target(ip: String, port: int) -> void:
	"""Set target IP and port"""
	target_ip = ip
	target_port = port
	print("VMCSender: Target set to %s:%d" % [ip, port])

func set_enabled(value: bool) -> void:
	"""Enable or disable sender"""
	enabled = value
	if enabled:
		print("VMCSender: Enabled")
	else:
		print("VMCSender: Disabled")

func _exit_tree() -> void:
	"""Cleanup when node is removed"""
	udp.close()
	print("VMCSender: Closed")
