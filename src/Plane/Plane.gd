extends KinematicBody


enum States {  CLIMB, CRUISE, DESCEND, LAND }

const PATH_DISTANCE:float = 6.0
const MAX_PITCH:float = 20.0
const MAX_ROLL:float = 60.0

export(float) var air_speed:float = 2.0
export(float) var pitch_speed:float = 5.0
export(float) var roll_speed:float = 1.0
export(float) var yaw_speed:float = 0.5

var current_turn_angle:float = 0.0
var state:int = States.CRUISE
var next_path_location:Vector3 = Vector3.ZERO

var current_leg:Spatial setget _set_current_leg

onready var mesh:MeshInstance = $MeshInstance
onready var lookat_test:Position3D = $LookAtTest
onready var test_label:Label3D = $Label3D
onready var next_path_test:MeshInstance = $NextPathTest


func _physics_process(delta):
	global_transform.origin -= global_transform.basis.z * delta * air_speed
	next_path_test.global_transform.origin = next_path_location
	
	check_path()
	handle_pitch(delta)
	handle_yaw(delta)
	handle_roll(delta)


func handle_pitch(delta) -> void:
	match(state):
		States.CLIMB: _pitch_mesh(MAX_PITCH, delta)
		States.CRUISE: _pitch_mesh(0, delta)
		States.DESCEND: _pitch_mesh(-MAX_PITCH, delta)
		States.LAND: _pitch_mesh(MAX_PITCH, delta)
	

func handle_roll(delta) -> void:
	var percentage_roll:float = clamp(current_turn_angle / 90, -1, 1)
	mesh.rotation_degrees.z = lerp(mesh.rotation_degrees.z, percentage_roll * MAX_ROLL, roll_speed * delta)


func handle_yaw(delta) -> void:
	lookat_test.look_at(next_path_location, Vector3.UP)
	var target_rotation:Quat = Quat(lookat_test.global_transform.basis).normalized()
	var current_rotation:Quat = Quat(global_transform.basis).normalized()
	
	var next_rotation:Quat = current_rotation.slerp(target_rotation, yaw_speed * delta)
	var next_basis = Basis(next_rotation)
	
	var turn_direction = global_transform.basis.z.signed_angle_to(next_basis.z, Vector3.UP)
	var turn_multiplier:int = 1 if turn_direction > 0 else -1
	current_turn_angle = rad2deg(current_rotation.angle_to(target_rotation)) * turn_multiplier
	
	test_label.text = String(current_turn_angle)
	global_transform.basis = next_basis


func check_path():
	if not is_instance_valid(current_leg): return
	
	if global_transform.origin.distance_to(next_path_location) < PATH_DISTANCE:
		if next_path_location == current_leg.get_entry(global_transform.origin):
			next_path_location = current_leg.get_exit()
		else:
			var current_pattern = current_leg.pattern
			var index_delta = -1 if current_pattern.direction == Globals.Directions.LEFT else 1
			var next_index = current_leg.index + index_delta
			
			
			var legs = current_pattern.legs.get_children()
			if legs.size() > next_index and next_index >= 0:
				self.current_leg = legs[next_index]


func _pitch_mesh(amount:float, delta:float) -> void:
	mesh.rotation_degrees.x = lerp(mesh.rotation_degrees.x, amount, delta * pitch_speed)


func _roll_mesh(amount:float, delta:float) -> void:
	mesh.rotation_degrees.z = lerp(mesh.rotation_degrees.z, amount, delta * roll_speed)


func _set_current_leg(leg):
	if current_leg == leg: return
	current_leg = leg
	
	var entry = leg.get_entry(global_transform.origin)
	next_path_location = entry
