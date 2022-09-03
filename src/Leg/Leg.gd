extends Spatial

const MIDPOINT_LEGS:Array = [Globals.Legs.DOWNWIND]
const NO_ENTRY_LEGS:Array = [Globals.Legs.DEPARTURE, Globals.Legs.CROSSWIND]


# The leg's physical direction and magnitude for scaling the mesh.
var start:Vector2 = Vector2.ZERO setget _set_start
var end:Vector2 = Vector2.ZERO setget _set_end

# The right/left direction of the parent pattern for the texture movement.
var direction:int setget _set_direction

# Derived label based on direction and index within the overall pattern
var label:String setget , _get_label
var index:int = 0
var index_directional:int = 0

var hovered:bool = false
var focused:bool = false setget _set_focused
var disabled:bool setget , _get_disabled
var full_name:String setget , _get_full_name

# Nodes
onready var pattern =  get_parent().get_parent()
onready var mesh:MeshInstance = $MeshInstance
onready var material:Material = mesh.get_surface_material(0)
onready var label_3d:Label3D = $Label3D


func _ready():
	update_direction_vector()
	
	var _a = Signals.connect("leg_clicked", self, "_on_leg_clicked")
	var _b = Signals.connect("plane_focused", self, "_on_plane_focused")


func update_direction_vector():
	if not is_instance_valid(material): return
	
	var is_left = direction == Globals.Directions.LEFT
	
	var vector:Vector2 = start - end
	var size = abs(vector.length())
	var shader_direction:Vector2 = Vector2.LEFT
	
	match(direction):
		Globals.Directions.RIGHT:
			shader_direction = Vector2.RIGHT
		Globals.Directions.LEFT:
			shader_direction = Vector2.LEFT
	
	var center = _get_center()
	global_transform.origin.x = center.x
	global_transform.origin.z = center.y
	look_at(Vector3(start.x, global_transform.origin.y, start.y), Vector3.UP)
	
	
	label_3d.text = self.label
	label_3d.rotation_degrees.y = 90 if is_left else -90
	
	mesh.scale.x = size
	material.set_shader_param("size", size)
	material.set_shader_param("direction", shader_direction)


func get_entry(from_point:Vector3) -> Vector3:
	var is_left = direction == Globals.Directions.LEFT
	var start_directional:Vector2 = end if is_left else start
	var start_3d:Vector3 = Vector3(start_directional.x, 0, start_directional.y)
	
	if MIDPOINT_LEGS.has(index_directional):
		# DOWNWIND legs can allow the plane to enter at the midpoint (center) if it's closer
		var center_2d = _get_center()
		var center = Vector3(center_2d.x, 0, center_2d.y)
		if from_point.distance_to(center) < from_point.distance_to(start_3d):
			return center
			
	return start_3d


func get_exit() -> Vector3:
	var is_left = direction == Globals.Directions.LEFT
	var end_directional:Vector2 = start if is_left else end
	return Vector3(end_directional.x, 0, end_directional.y)


func _get_center() -> Vector2:
	var x = (start.x + end.x) / 2
	var y = (start.y + end.y) / 2
	
	return Vector2(x,  y)


func _set_start(value:Vector2) -> void:
	start = value
	update_direction_vector()


func _set_end(value:Vector2) -> void:
	end = value
	update_direction_vector()


func _set_direction(value:int) -> void:
	direction = value
	
	_update_index_directional()
	update_direction_vector()


func _set_focused(value) -> void:
	if focused == value: return
	focused = value
	
	var color = Colors.GREEN
	if focused: color = Colors.YELLOW
	material.set_shader_param("color", color)


func _get_label() -> String:
	return Globals.Legs.keys()[index_directional]


func _get_disabled() -> bool:
	return NO_ENTRY_LEGS.has(index_directional)


func _get_full_name() -> String:
	var directions =  Globals.Directions
	var runway = pattern.runway.name_left if pattern.direction == directions.LEFT else pattern.runway.name_right
	
	return "%s %s %s" % [runway, directions.keys()[pattern.direction], _get_label()]


func _update_index_directional() -> void:
	# Invert the index so that it properly selects from the Globals
	# in the new direction (left: inverse / right: normal)
	if direction == Globals.Directions.LEFT:
		index_directional = Globals.Legs.size() - 1 - index
	else:
		index_directional = index


func _on_Area_mouse_entered():
	label_3d.show()
	hovered = true


func _on_Area_mouse_exited():
	label_3d.hide()
	hovered = false


func _on_Area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if hovered and not self.disabled:
				Signals.emit_signal("leg_clicked", self)
				self.focused = !focused


func _on_leg_clicked(leg):
	if leg != self: self.focused = false


func _on_plane_focused(plane):
	if plane != null:
		self.focused = plane.current_leg == self
