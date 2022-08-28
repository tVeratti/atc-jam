extends Spatial


onready var test_pattern = $Pattern


func _on_Flip_pressed():
	if test_pattern.direction == Globals.Directions.LEFT:
		test_pattern.direction = Globals.Directions.RIGHT
	else:
		test_pattern.direction = Globals.Directions.LEFT
