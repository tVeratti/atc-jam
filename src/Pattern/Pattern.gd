extends Spatial


class_name Pattern


signal direction_changed(value)


const LegScene = preload("res://Leg/Leg.tscn")

const SCALE:float = 0.1


# Vars
# ----------------------------
export(Globals.Directions) var direction:int = Globals.Directions.LEFT setget _set_direction

# Nodes
# ----------------------------
onready var legs:Spatial = $Legs
onready var map_reference:Line2D = $MapReference


func _ready():
	construct_path_mesh()


# Using the path node, build meshes that can be textured with shaders
# in order to display each leg and the pattern direction.
func construct_path_mesh():
	
	var index:int = 0
	var path:PoolVector2Array = map_reference.points
	var path_size:int = path.size()
	
	for leg in Globals.Legs.keys():
		
		if path_size > index:
			var leg_scene = LegScene.instance()
			if path_size > index + 1:
				leg_scene.start = path[index] * SCALE
				leg_scene.end = path[index + 1] * SCALE
			else: break
			
			leg_scene.index = index
			leg_scene.direction = direction
			legs.add_child(leg_scene)
			connect("direction_changed", leg_scene, "_set_direction")
			
		index += 1


func _set_direction(value:int) -> void:
	direction = value
	emit_signal("direction_changed", direction)
