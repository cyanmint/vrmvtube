extends Node

## MediaPipe UDP Receiver for VRMVTube
##
## Receives real-time face tracking data from MediaPipe Python bridge via UDP
## and passes it to the webcam tracker for VRM avatar animation.
##
## Setup:
## 1. Install Python dependencies: pip install mediapipe opencv-python
## 2. Run the MediaPipe bridge: python tools/mediapipe_bridge.py
## 3. This node will automatically receive and process the tracking data
##
## Created by: GitHub Copilot

signal tracking_data_received(data: Dictionary)

const UDP_PORT: int = 9999
const RECONNECT_INTERVAL: float = 5.0

var udp := PacketPeerUDP.new()
var is_connected: bool = false
var last_packet_time: float = 0.0
var total_packets_received: int = 0
var reconnect_timer: float = 0.0

func _ready() -> void:
	_bind_udp_port()

func _bind_udp_port() -> void:
	"""Bind to UDP port for receiving tracking data"""
	var err := udp.bind(UDP_PORT)
	if err != OK:
		push_error("MediaPipeReceiver: Failed to bind UDP port %d (error %d)" % [UDP_PORT, err])
		is_connected = false
	else:
		print("MediaPipeReceiver: Listening on UDP port %d" % UDP_PORT)
		print("MediaPipeReceiver: Run 'python tools/mediapipe_bridge.py' to start tracking")
		is_connected = true

func _process(delta: float) -> void:
	if not is_connected:
		# Try to reconnect periodically
		reconnect_timer += delta
		if reconnect_timer >= RECONNECT_INTERVAL:
			reconnect_timer = 0.0
			_bind_udp_port()
		return
	
	# Process all available packets
	var packets_this_frame: int = 0
	while udp.get_available_packet_count() > 0:
		var packet := udp.get_packet()
		_process_packet(packet)
		packets_this_frame += 1
		
		# Limit packets per frame to avoid blocking
		if packets_this_frame >= 5:
			break

func _process_packet(packet: PackedByteArray) -> void:
	"""Process a single UDP packet containing tracking data"""
	var json_str := packet.get_string_from_utf8()
	
	# Parse JSON data
	var json := JSON.new()
	var parse_result := json.parse(json_str)
	
	if parse_result != OK:
		push_warning("MediaPipeReceiver: Failed to parse JSON (error at line %d)" % json.get_error_line())
		return
	
	var data = json.get_data()
	if data == null or not data is Dictionary:
		push_warning("MediaPipeReceiver: Invalid data format")
		return
	
	# Convert head_rotation dict to Vector3 if present
	if data.has("head_rotation") and data["head_rotation"] is Dictionary:
		var rot_dict: Dictionary = data["head_rotation"]
		data["head_rotation"] = Vector3(
			rot_dict.get("x", 0.0),
			rot_dict.get("y", 0.0),
			rot_dict.get("z", 0.0)
		)
	
	# Convert head_position dict to Vector3 if present
	if data.has("head_position") and data["head_position"] is Dictionary:
		var pos_dict: Dictionary = data["head_position"]
		data["head_position"] = Vector3(
			pos_dict.get("x", 0.0),
			pos_dict.get("y", 0.0),
			pos_dict.get("z", 0.0)
		)
	
	# Update statistics
	total_packets_received += 1
	last_packet_time = Time.get_ticks_msec() / 1000.0
	
	# Emit signal with tracking data
	tracking_data_received.emit(data)

func get_status() -> Dictionary:
	"""Get receiver status information"""
	var current_time := Time.get_ticks_msec() / 1000.0
	var time_since_packet := current_time - last_packet_time
	
	return {
		"is_connected": is_connected,
		"port": UDP_PORT,
		"total_packets": total_packets_received,
		"time_since_last_packet": time_since_packet,
		"is_receiving": time_since_packet < 1.0  # Consider active if packet within 1 second
	}

func _exit_tree() -> void:
	"""Cleanup when node is removed"""
	udp.close()
	print("MediaPipeReceiver: Closed UDP connection")
