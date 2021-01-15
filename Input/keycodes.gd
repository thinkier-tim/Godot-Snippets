extends Node

func _input(event):
	if event is InputEventKey:
		var inKey = event.scancode
		print("Keypress detected: ", inKey, ", key = ", OS.get_scancode_string(inKey))
