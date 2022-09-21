extends Node3D


@export var name_left:String = ""
@export var name_right:String = ""

@onready var runway_center:Marker3D = $MeshInstance3D/Marker3D


func _ready():
	Signals.runway_ready.emit(self)
