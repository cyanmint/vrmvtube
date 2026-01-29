extends Node

## OSC (Open Sound Control) Implementation for Godot
##
## Provides basic OSC message parsing and sending over UDP
## Used as foundation for VMC protocol support
##
## Based on OSC 1.0 specification
## Created by: GitHub Copilot

class_name OSC

# OSC type tags
const TYPE_INT32 = 'i'
const TYPE_FLOAT32 = 'f'
const TYPE_STRING = 's'
const TYPE_BLOB = 'b'
const TYPE_TRUE = 'T'
const TYPE_FALSE = 'F'
const TYPE_NIL = 'N'

static func pack_message(address: String, args: Array) -> PackedByteArray:
	"""Pack an OSC message into bytes"""
	var buffer := PackedByteArray()
	
	# Add address string
	buffer.append_array(_pack_string(address))
	
	# Build type tag string
	var type_tags := ","
	for arg in args:
		if arg is int:
			type_tags += TYPE_INT32
		elif arg is float:
			type_tags += TYPE_FLOAT32
		elif arg is String:
			type_tags += TYPE_STRING
		elif arg is bool:
			type_tags += TYPE_TRUE if arg else TYPE_FALSE
		elif arg == null:
			type_tags += TYPE_NIL
	
	# Add type tags
	buffer.append_array(_pack_string(type_tags))
	
	# Add arguments
	for i in range(args.size()):
		var arg = args[i]
		var type_tag = type_tags[i + 1]  # Skip comma
		
		match type_tag:
			TYPE_INT32:
				buffer.append_array(_pack_int32(arg))
			TYPE_FLOAT32:
				buffer.append_array(_pack_float32(arg))
			TYPE_STRING:
				buffer.append_array(_pack_string(arg))
			TYPE_TRUE, TYPE_FALSE, TYPE_NIL:
				pass  # No data for these types
	
	return buffer

static func unpack_message(data: PackedByteArray) -> Dictionary:
	"""Unpack an OSC message from bytes"""
	var result := {
		"address": "",
		"args": []
	}
	
	var offset := 0
	
	# Read address
	var address_result := _unpack_string(data, offset)
	result.address = address_result[0]
	offset = address_result[1]
	
	# Read type tags
	var type_tags_result := _unpack_string(data, offset)
	var type_tags: String = type_tags_result[0]
	offset = type_tags_result[1]
	
	# Type tags should start with comma
	if type_tags.length() == 0 or type_tags[0] != ',':
		push_error("OSC: Invalid type tags")
		return result
	
	# Read arguments
	for i in range(1, type_tags.length()):
		var type_tag := type_tags[i]
		
		match type_tag:
			TYPE_INT32:
				var int_result := _unpack_int32(data, offset)
				result.args.append(int_result[0])
				offset = int_result[1]
			TYPE_FLOAT32:
				var float_result := _unpack_float32(data, offset)
				result.args.append(float_result[0])
				offset = float_result[1]
			TYPE_STRING:
				var string_result := _unpack_string(data, offset)
				result.args.append(string_result[0])
				offset = string_result[1]
			TYPE_TRUE:
				result.args.append(true)
			TYPE_FALSE:
				result.args.append(false)
			TYPE_NIL:
				result.args.append(null)
	
	return result

# Private helper functions

static func _pack_string(s: String) -> PackedByteArray:
	"""Pack a null-terminated string with padding to 4-byte boundary"""
	var bytes := s.to_utf8_buffer()
	bytes.append(0)  # Null terminator
	
	# Pad to 4-byte boundary
	while bytes.size() % 4 != 0:
		bytes.append(0)
	
	return bytes

static func _pack_int32(value: int) -> PackedByteArray:
	"""Pack a 32-bit integer (big-endian)"""
	var bytes := PackedByteArray()
	bytes.resize(4)
	bytes.encode_s32(0, value)
	
	# Convert to big-endian
	bytes.reverse()
	return bytes

static func _pack_float32(value: float) -> PackedByteArray:
	"""Pack a 32-bit float (big-endian)"""
	var bytes := PackedByteArray()
	bytes.resize(4)
	bytes.encode_float(0, value)
	
	# Convert to big-endian
	bytes.reverse()
	return bytes

static func _unpack_string(data: PackedByteArray, offset: int) -> Array:
	"""Unpack a null-terminated string, return [string, new_offset]"""
	var end := offset
	while end < data.size() and data[end] != 0:
		end += 1
	
	var string_bytes := data.slice(offset, end)
	var string := string_bytes.get_string_from_utf8()
	
	# Skip to next 4-byte boundary
	var new_offset := ((end + 4) / 4) * 4
	
	return [string, new_offset]

static func _unpack_int32(data: PackedByteArray, offset: int) -> Array:
	"""Unpack a 32-bit integer (big-endian), return [int, new_offset]"""
	var bytes := data.slice(offset, offset + 4)
	bytes.reverse()  # Convert from big-endian
	var value := bytes.decode_s32(0)
	return [value, offset + 4]

static func _unpack_float32(data: PackedByteArray, offset: int) -> Array:
	"""Unpack a 32-bit float (big-endian), return [float, new_offset]"""
	var bytes := data.slice(offset, offset + 4)
	bytes.reverse()  # Convert from big-endian
	var value := bytes.decode_float(0)
	return [value, offset + 4]
