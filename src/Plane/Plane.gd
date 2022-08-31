extends KinematicBody


enum States {  CLIMB, CRUISE, DESCEND, LAND }

const PATH_DISTANCE:float = 6.0
const CIRCLE_DISTANCE:float = 40.0
const MAX_PITCH:float = 20.0
const MAX_ROLL:float = 60.0

export(float) var air_speed:float = 2.0
export(float) var pitch_speed:float = 5.0
export(float) var roll_speed:float = 1.0
export(float) var yaw_speed:float = 0.5

var color
var animal
var number
var call_sign setget , _get_call_sign

var state:int = States.CRUISE
var next_path_location:Vector3 = Vector3.ZERO
var _saved_path_location:Vector3 = Vector3.ZERO
var _path_override:bool = false

var current_turn_angle:float = 0.0
var current_leg:Spatial setget _set_current_leg
var current_vector:Vector3 = Vector3.ZERO setget _set_current_vector

var hovered:bool = false setget _set_hovered
var focused:bool = false setget _set_focused

onready var mesh:MeshInstance = $MeshInstance
onready var outline:MeshInstance = get_node("%Outline")
onready var lookat_test:Position3D = $LookAtTest
onready var sign_label:Label3D = $Label3D
onready var path_raycast:RayCast = $PathCheckRayCast
onready var path_timer:Timer = $PathCheckTimer
onready var path_mesh:MeshInstance = $PathMesh


func _ready():
	generate_identity()
	sign_label.text = self.call_sign
	
	var _a = Signals.connect("plane_hovered", self, "_on_plane_hovered_global")
	var _b = Signals.connect("plane_focused", self, "_on_plane_focused_global")


func generate_identity():
	color = Random.get_random_item(Colors.PLANE_COLORS.keys())
	animal = Random.get_random_item(Globals.ANIMALS)
	number = randi() % 1000


func _physics_process(delta):
	global_transform.origin -= global_transform.basis.z * delta * air_speed
	
	check_path()
	check_raycast()
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
	var target_rotation:Quat = lookat_test.global_transform.basis.get_rotation_quat()
	var current_rotation:Quat = global_transform.basis.get_rotation_quat()
	
	var next_rotation:Quat = current_rotation.slerp(target_rotation, yaw_speed * delta)
	var next_basis = Basis(next_rotation)
	
	var turn_direction = global_transform.basis.z.signed_angle_to(next_basis.z, Vector3.UP)
	var turn_multiplier:int = 1 if turn_direction > 0 else -1
	current_turn_angle = rad2deg(current_rotation.angle_to(target_rotation)) * turn_multiplier
	
	global_transform.basis = next_basis


func check_path():
	if not is_instance_valid(current_leg): return # not on a pattern yet
	
	path_mesh.global_transform.origin = next_path_location
	if global_transform.origin.distance_to(next_path_location) < PATH_DISTANCE:
		if next_path_location == current_leg.get_entry(global_transform.origin):
			path_raycast.enabled = false
			next_path_location = current_leg.get_exit()
		elif next_path_location == current_leg.get_exit():
			path_raycast.enabled = false
			var current_pattern = current_leg.pattern
			var index_delta = 1 if current_pattern.direction == Globals.Directions.RIGHT else -1
			var next_index = current_leg.index + index_delta
			
			var legs = current_pattern.legs.get_children()
			if next_index < 0 or next_index > legs.size():
				# The plane is arriving at the runway (end)
				land()
				return
			
			self.current_leg = legs[next_index]


func check_raycast():
	var path:Vector3 = _saved_path_location if _path_override else next_path_location
	path_raycast.look_at(path, Vector3.UP)
	path_raycast.force_raycast_update()
	
	if _path_override and path_timer.is_stopped():
		_path_override = false
		next_path_location = _saved_path_location
	
	if not path_raycast.enabled: return
	if path_raycast.is_colliding() and not _path_override:
		var collider:Spatial = path_raycast.get_collider().get_parent().get_parent()
		var collision_point:Vector3 = path_raycast.get_collision_point()
		if collider.has_method("get_entry"):
			if collider != current_leg and collision_point.distance_to(path) > PATH_DISTANCE:
				# Avoid until the raycast can safely reach
				# Temporarily override the desired path
				_update_path_to_avoid(collision_point)
				path_timer.start()
				return
			else:
				path_raycast.enabled = false


func land():
	Signals.emit_signal("plane_landed", self)
	queue_free()


func _pitch_mesh(amount:float, delta:float) -> void:
	mesh.rotation_degrees.x = lerp(mesh.rotation_degrees.x, amount, delta * pitch_speed)


func _roll_mesh(amount:float, delta:float) -> void:
	mesh.rotation_degrees.z = lerp(mesh.rotation_degrees.z, amount, delta * roll_speed)


func _update_path_to_avoid(collision_point:Vector3):
	var origin:Vector3 = global_transform.origin
	var origin_2d:Vector2 = Vector2(origin.x, origin.z)
	var angle:float = origin_2d.angle_to_point(Vector2.ZERO) + deg2rad(20.0)
	
	var x:float = CIRCLE_DISTANCE * cos(angle)
	var y:float = CIRCLE_DISTANCE * sin(angle)
	
	var next_point:Vector3 = global_transform.origin - (lookat_test.global_transform.basis.z * 10)
	
	if not _path_override:
		_saved_path_location = next_path_location
		_path_override = true
	
	next_path_location = Vector3(x, 0, y)


# Getters/Setters
# ------------------------------- 

func _get_call_sign() -> String:
	return "%s %s %s" % [color, animal, number]


func _set_current_leg(leg) -> void:
	if current_leg == leg: return
	current_leg = leg
	
	var entry = leg.get_entry(global_transform.origin)
	next_path_location = entry


func _set_current_vector(value) -> void:
	current_vector = value
	current_leg = null
	
	var origin = global_transform.origin
	next_path_location = origin.direction_to(origin + current_vector) * 999


func _set_hovered(value) -> void:
	if hovered == value: return
	hovered = value


func _set_focused(value) -> void:
	if focused == value: return
	
	focused = value
	if focused: outline.show()
	else: outline.hide()


# Global Signals
# -------------------------------

func _on_plane_hovered_global(other):
	self.hovered = other == self


func _on_plane_focused_global(other):
	self.focused = other == self


# Node Signals
# -------------------------------

func _on_Area_mouse_entered():
	self.hovered = true
	Signals.emit_signal("plane_hovered", self)
	

func _on_Area_mouse_exited():
	self.hovered = false
	Signals.emit_signal("plane_hovered", null)


func _on_Area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if hovered:
				self.focused = !focused
				Signals.emit_signal("plane_focused", self if focused else null)


func _on_PathCheckTimer_timeout():
	pass
