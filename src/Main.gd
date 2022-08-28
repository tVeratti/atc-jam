extends Spatial



func _on_Flip_pressed():
	var patterns = get_tree().get_nodes_in_group("pattern")
	for test_pattern in patterns:
		if test_pattern.direction == Globals.Directions.LEFT:
			test_pattern.direction = Globals.Directions.RIGHT
		else:
			test_pattern.direction = Globals.Directions.LEFT
