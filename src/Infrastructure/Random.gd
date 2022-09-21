extends Object

class_name Random

static func get_random_item(array:Array):
	if array.size() == 0: return null
	
	var index = get_random_index(array)
	return array[index]
	

static func get_random_index(array:Array) -> int:
	var max_index = array.size()
	return roll(max_index)


static func roll(maximum:int) -> int:
	randomize()
	return int(randf_range(0, maximum)) # int() rounds down
