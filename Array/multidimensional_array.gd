extends Node

func _ready():
	test_flatten_matrix()


# returns a flat array when passed a matrix
func flatten_matrix(input_array, out_array) -> Array:
	var flat_array = out_array
	for item in input_array:
		if typeof(item) == TYPE_ARRAY:
			var _discard = flatten_matrix(item, flat_array)
		else:
			flat_array.append(item)
	return flat_array


func test_flatten_matrix():
	var test_matrix = []
	var flat_array = []
	for x in range(0, 5):
		test_matrix.append([])
		for y in range(0, 3):
			test_matrix[x].append((x + 1) * (y + 1))
	print("test_flatten_matrix(): input = ", test_matrix)
	print("test_flatten_matrix(): output = ", flatten_matrix(test_matrix, flat_array))
