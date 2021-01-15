extends Node

# Autoload Singleton to handle InputMap actions
# TODO: save keybindings after user customization
# TODO: allow reverting to defaults

export var action_keys = {
	"move_forward":KEY_W,
	"move_backward":KEY_S,
	"move_left":KEY_A,
	"move_right":KEY_D,
	"move_up":KEY_SPACE,
	"move_down":KEY_CONTROL,
	"sprint_toggle":KEY_SHIFT,
	"perspective_toggle":KEY_P,
	"reload":KEY_R
}

export var action_buttons = {
	"select": BUTTON_LEFT,
	"interact": BUTTON_RIGHT,
	"switch_item_forward": BUTTON_WHEEL_DOWN,
	"switch_item_reverse": BUTTON_WHEEL_UP
}


func set_action_keys():
	print("adding action keys...")
	for key in action_keys:
		print(".. adding ", key, " (", action_keys[key], ")")
		InputMap.add_action(key)
		var new_input = InputEventKey.new()
		new_input.scancode = action_keys[key]
		InputMap.action_add_event(key,new_input)
	print("... done.")


func set_action_buttons():
	print("adding action buttons...")
	for action in action_buttons:
		print(".. adding ", action, " (", action_buttons[action], ")")
		InputMap.add_action(action)
		var new_button = InputEventMouseButton.new()
		new_button.button_index = action_buttons[action]
		InputMap.action_add_event(action, new_button)
	print("... done.")


func display_all_actions():
	for action in InputMap.get_actions():
		print(action,": ", InputMap.get_action_list(action))


func _ready():
	# add input mappings
	set_action_buttons()
	set_action_keys()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
