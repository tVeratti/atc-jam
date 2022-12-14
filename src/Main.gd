extends Node3D


var PlaneScene = load("res://Plane/Plane.tscn")

const SPAWN_MULTIPLIER:float = 80.0
const MAX_SPAWN_TIME:int = 45
const MIN_SPAWN_TIME:int = 15
const MAX_PLANES:int = 3

var active_plane:Node3D
var runway_center:Vector3 = Vector3.ZERO

@onready var planes:Node3D = $Planes
@onready var spawn_timer:Timer = $Planes/SpawnTimer


func _ready():
	randomize()
	
	var _a = Signals.leg_clicked.connect(self._on_leg_clicked)
	var _b = Signals.plane_focused.connect(self._on_plane_focused)


func spawn_plane():
	var spawn_location_direction:Vector3 = Vector3(
		randf_range(-1, 1),
		0,
		randf_range(-1, 1)).normalized()
	
	var spawn_location:Vector3 = spawn_location_direction * SPAWN_MULTIPLIER
	var initial_vector:Vector3 = spawn_location_direction * -1
	
	var new_plane = PlaneScene.instantiate()
	new_plane.hide()
	planes.add_child(new_plane)
	
	new_plane.global_transform.origin = spawn_location
	new_plane.current_vector = initial_vector
	new_plane.show()
	
	Signals.plane_spawned.emit(new_plane)


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


func _on_SpawnTimer_timeout():
	if get_tree().get_nodes_in_group("plane").size() < MAX_PLANES:
		spawn_plane()

	var new_timer:int = (randi() % MAX_SPAWN_TIME) + MIN_SPAWN_TIME
	spawn_timer.start(new_timer)
