extends Node3D


class_name Pattern


signal direction_changed(value)


const LegScene = preload("res://Leg/Leg.tscn")

const SCALE:float = 0.1


# Vars
# ----------------------------
@export var direction:int = Globals.Directions.LEFT:
	set(value):
		if value == direction: return
		direction = value
		direction_changed.emit(direction)


# Nodes
# ----------------------------
@onready var legs:Node3D = $Legs
@onready var map_reference:Line2D = $MapReference
@onready var runway:Node3D = get_parent()


func _ready():
	construct_path_mesh()


# Using the path node, build meshes that can be textured with shaders
# in order to display each leg and the pattern direction.
func construct_path_mesh():
	var index:int = 0
	var path:PackedVector2Array = map_reference.points
	var path_size:int = path.size()
	
	for leg in Globals.Legs.keys():
		
		if path_size > index:
			var leg_scene = LegScene.instantiate()
			if path_size > index + 1:
				leg_scene.start = path[index] * SCALE
				leg_scene.end = path[index + 1] * SCALE
			else: break
			
			leg_scene.index = index
			leg_scene.direction = direction
			legs.add_child(leg_scene)
			
			# If the pattern direction changes, update all legs with the new direction
			direction_changed.connect(leg_scene.update_direction)
			
		index += 1
