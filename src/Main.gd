extends Spatial


const PlaneScene = preload("res://Plane/Plane.tscn")

const SPAWN_MULTIPLIER:float = 100.0

var active_plane:Spatial

onready var planes:Spatial = $Planes


func _ready():
	randomize()
	
	spawn_plane()
	
	var _a = Signals.connect("leg_clicked", self, "_on_leg_clicked")
	var _b = Signals.connect("plane_focused", self, "_on_plane_focused")


func spawn_plane():
	var spawn_location_direction:Vector3 = Vector3(randf(), 0, randf()).normalized()
	var spawn_location:Vector3 = spawn_location_direction * SPAWN_MULTIPLIER
	var initial_vector:Vector3 = spawn_location_direction * -1
	
	var new_plane = PlaneScene.instance()
	new_plane.hide()
	planes.add_child(new_plane)
	
	new_plane.global_transform.origin = spawn_location
	new_plane.current_vector = initial_vector
	new_plane.show()
	
	Signals.emit_signal("plane_spawned", new_plane)


func _on_Flip_pressed():
	var patterns = get_tree().get_nodes_in_group("pattern")
	for test_pattern in patterns:
		if test_pattern.direction == Globals.Directions.LEFT:
			test_pattern.direction = Globals.Directions.RIGHT
		else:
			test_pattern.direction = Globals.Directions.LEFT


func _on_leg_clicked(leg):
	if is_instance_valid(active_plane):
		active_plane.current_leg = leg


func _on_plane_focused(plane):
	active_plane = plane
