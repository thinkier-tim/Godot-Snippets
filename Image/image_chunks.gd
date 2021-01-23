extends Node2D
class_name ImageManipulation

func __summary():
	var _descriptive_text ="""
	Two-Dimensional Wave Function Collapse for level generating, etc.
	-----------------------------------------------------------------
	core concepts, as described by Brian Bucklew:
	 https://www.youtube.com/watch?v=fnFj3dOKcIQ
	 Brian Bucklew - Dungeon Generation via Wave Function Collapse
	
	1:
		a: input is divided into NxN tiles
		b: overlap with other tiles is calculated
	
	2:
		output is initialized with each pixel being a full
		 superposition of possible output tiles
	
	3:
		a: lowest entropy NxN area is selected from the output
		b: one option is selected at random from remaining possibilities
	
	4:
		a: new information based on (3) is propogated to adjacent sectors
		b: possibilities that can no longer overlap are removed
	
	5:
		if any elements are still uncollapsed, goto 2.
	"""

const CHUNK_WIDTH_MINIMUM = 2
const CHUNK_WIDTH_MAXIMUM = 5
const CHUNK_HEIGHT_MINIMUM = 2
const CHUNK_HEIGHT_MAXIMUM = 5


export var input_image : StreamTexture	# the image to calculate from (png is streamtexture?)
export var chunk_resolution : Vector2 = Vector2(3, 3) setget validate_chunk_resolution

export var chunks : Array	# exported for runtime visibility at debug, move back into process_input_image for production


func _ready():
	process_input_image(input_image)


func process_input_image(image_to_chunk : StreamTexture):
	var image_data = image_to_chunk.get_data()
	chunks = break_input_into_chunks(image_data, chunk_resolution)
	chunks = mangle_candidates(chunks)
	debug_array_images(chunks)	# pull this before production


func break_input_into_chunks(image_to_chunk : Image, resolution : Vector2 = Vector2(3, 3)) -> Array:
	var chunk = []
	for x in range(0, image_to_chunk.get_width() - (resolution.x - 1)):
		for y in range(0, image_to_chunk.get_height() - (resolution.y - 1)):
			chunk.append(image_chunk(image_to_chunk, Vector2(x, y), resolution))
	return prune_duplicate_images_from_array(chunk)


func image_chunk(chunk_source : Image, source_location : Vector2, resolution : Vector2 = Vector2(3, 3)) -> Image:
	var image_chunk = Image.new()
	image_chunk.create(int(resolution.x), int(resolution.y), false, Image.FORMAT_RGBA8)
	image_chunk.blit_rect(chunk_source, Rect2(source_location, resolution), Vector2.ZERO)
	return image_chunk


func prune_duplicate_images_from_array(image_array_to_prune) -> Array:
	var output_images = []
	for i in range(0, image_array_to_prune.size()):
		var duplicate_found = false
		var current_image = image_array_to_prune[i]
		
		for j in range(i + 1, image_array_to_prune.size()):
			var next_image = image_array_to_prune[j]
			if images_are_the_same(current_image, next_image):
				duplicate_found = true
				continue
		
		if !duplicate_found:
			output_images.append(current_image)
	
	return output_images


func validate_chunk_resolution(image_resolution) -> Vector2:
	chunk_resolution.x = int(clamp(image_resolution.x, CHUNK_WIDTH_MINIMUM, CHUNK_WIDTH_MAXIMUM))
	chunk_resolution.y = int(clamp(image_resolution.y, CHUNK_HEIGHT_MINIMUM, CHUNK_HEIGHT_MAXIMUM))
	return chunk_resolution


func debug_array_images(image_array, root_folder : String = "debug_array_images"):
	var d : Directory = Directory.new()
	if !d.dir_exists(str("res://", root_folder, "/")):
		var _creation = d.make_dir_recursive(str("res://", root_folder, "/"))
	var _uncreation = d.unreference()
	
	var picture_count = 0
	for picture in image_array:
		picture_count += 1
		picture.save_png(str("res://", root_folder, "/image_", picture_count, ".png"))
	print("debug_array_images() complete, output is in res://", root_folder, "/")


func images_are_the_same(image_1 : Image, image_2 : Image) -> bool:
	# because "image1 == image2" returns false even when pixels are identical
	return array_from_image(image_1) == array_from_image(image_2)


func array_from_image(image_to_arrayify : Image) -> Array:
	var out = []
	image_to_arrayify.lock()
	for x in image_to_arrayify.get_size().x:
		for y in image_to_arrayify.get_size().y:
			out.append(image_to_arrayify.get_pixel(x, y))
	image_to_arrayify.unlock()
	return out


func mangle_candidates(images_to_mangle):
	var array_in_progress = []
	for this_image in prune_duplicate_images_from_array(images_to_mangle):
		array_in_progress.append(this_image)
		for _i in range(0, 2):
			this_image = rotate_right(this_image)
			assert(this_image != null,"Wave Function Collapse::create_candidates(): generated null image on rotate")
			array_in_progress.append(this_image)
			
			this_image.flip_x()
			assert(this_image != null,"Wave Function Collapse::create_candidates(): generated null image on reverse")
			array_in_progress.append(this_image)
			
			this_image.flip_x()
			this_image.flip_y()
			assert(this_image != null,"Wave Function Collapse::create_candidates(): generated null image on invert")
			array_in_progress.append(this_image)
	return prune_duplicate_images_from_array(array_in_progress)


func rotate_right(image_to_rotate : Image):
	var out_image = Image.new()
	var image_size = image_to_rotate.get_size()
	var image_format = image_to_rotate.get_format()
	out_image.create(int(image_size.x), int(image_size.y), false, image_format)
	image_to_rotate.lock()
	out_image.lock()
	for column in range(0, int(image_size.x)):
		for row in range(0, int(image_size.y)):
			var pixel_color = image_to_rotate.get_pixel(row, int(image_size.x) - column - 1)
			out_image.set_pixel(column, row, pixel_color)
	out_image.unlock()
	image_to_rotate.unlock()
	return out_image
