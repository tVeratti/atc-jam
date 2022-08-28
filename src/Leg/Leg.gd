extends Spatial

# The leg's physical direction and magnitude for scaling the mesh.
var start:Vector2 = Vector2.ZERO setget _set_start
var end:Vector2 = Vector2.ZERO setget _set_end

# The right/left direction of the parent pattern for the texture movement.
var direction:int setget _set_direction

# Derived label based on direction and index within the overall pattern
var label:String setget , _get_label
var index:int = 0

# Nodes
onready var mesh:MeshInstance = $MeshInstance
onready var material:Material = mesh.get_surface_material(0)
onready var label_3d:Label3D = $Label3D


func _ready():
	update_direction_vector()


func update_direction_vector():
	if not is_instance_valid(material): return
	
	var vector:Vector2 = start - end
	var size = abs(vector.length())
	var shader_direction:Vector2 = Vector2.LEFT
	
	match(direction):
		Globals.Directions.RIGHT:
			shader_direction = Vector2.RIGHT
		Globals.Directions.LEFT:
			shader_direction = Vector2.LEFT
	
	var center = _get_center()
	global_transform.origin = Vector3(center.x, 0, center.y)
	look_at(Vector3(start.x, 0, start.y), Vector3.UP)
	
	
	label_3d.text = self.label
	
	mesh.scale.x = size
	material.set_shader_param("size", size)
	material.set_shader_param("direction", shader_direction)


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
	update_direction_vector()


func _get_label() -> String:
	var keys =  Globals.Legs.keys().duplicate()
	if direction == Globals.Directions.LEFT: keys.invert()
	return keys[index]
