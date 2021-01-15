extends Node

# instructions:
# ------------
# make a new project
# add this script to the root node
# press F5 or click the play button
# marvel at the changing "green-ness" of the progress bar

var value_modifier = 1	# sets direction of progressbar travel for automatic cycling

var foreground_handle : StyleBox = StyleBoxFlat.new()
	# used as a "handle" to the foreground of the progress bar

var the_bar: = ProgressBar.new() # the progress bar, in case that wasn't clear

func _ready():
	# add the progress bar to the tree so we can see it
	add_child(the_bar)
	# set the progress bar's position
	the_bar.margin_left = 100
	the_bar.margin_top = 100
	# set progress bar size
	the_bar.margin_right = 300
	the_bar.margin_bottom = 150

	# initialize variables to allow changing the foreground color
	the_bar.set("custom_styles/fg", foreground_handle)		# enable foreground color to be changed
	foreground_handle = the_bar.get("custom_styles/fg")	# circular cleverness; grab a reference
	# set foreground's background color to black (is that ironic?)
	foreground_handle.bg_color = Color.black

	# alternate method for the background, less memory-conscious
	# we can get away with it because we're only setting it once
	the_bar.set("custom_styles/bg", StyleBoxFlat.new())
	the_bar.get("custom_styles/bg").bg_color = Color.black
	
	# set the font color to something we can read against black or green
	the_bar.set("custom_colors/font_color", Color.rebeccapurple)

var new_color : Color	# used to set the color of the progress bar
func _process(delta):
	# automatically move the slider value
	if the_bar.value >= the_bar.max_value:
		value_modifier = -1
	elif the_bar.value <= the_bar.min_value:
		value_modifier = 1
	the_bar.value += value_modifier

	# change the "green-ness" of the progressbar based on slider value
	new_color = foreground_handle.bg_color	# flexible, because why not?
	new_color.g = the_bar.value / the_bar.max_value	# not all bars are 0-100
	foreground_handle.bg_color = new_color
