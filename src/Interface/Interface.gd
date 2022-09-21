extends Control


const PlaneAvatarScene = preload("res://Interface/PlaneAvatar.tscn")

@onready var planes:VBoxContainer = $Planes


func _ready():
	Signals.connect("plane_spawned",Callable(self,"_on_plane_spawned"))


func _on_plane_spawned(plane):
	var plane_scene = PlaneAvatarScene.instantiate()
	plane_scene.plane = plane
	planes.add_child(plane_scene)
