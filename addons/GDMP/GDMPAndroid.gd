extends Node

func _enter_tree() -> void:
	print("GDMPAndroid: Loading native library for Android...")
	var System := JavaClassWrapper.wrap("java.lang.System")
	if System == null:
		push_error("GDMPAndroid: Failed to wrap java.lang.System - not on Android?")
		return
	
	print("GDMPAndroid: Calling System.loadLibrary('GDMP.android')...")
	System.call("loadLibrary", "GDMP.android")
	print("GDMPAndroid: ✅ Native library loaded successfully")
