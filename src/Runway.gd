extends Spatial


export(String) var name_left:String = ""
export(String) var name_right:String = ""

onready var runway_center:Position3D = $MeshInstance/Position3D

func _ready():
	Signals.emit_signal("runway_ready", self)
