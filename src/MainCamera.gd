extends Camera


func _process(delta):
	var patterns = get_tree().get_nodes_in_group("pattern")
	if patterns.empty(): return
#
#	look_at(patterns[0].global_transform.origin, Vector3.UP)
