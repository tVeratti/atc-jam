extends Node3D

const Y_DISTANCE_MAX:float = 50.0
const Y_DISTANCE_MIN:float = 10.0

var target_speed:float = 0.8
var camera_speed:float = 3.0
var scroll_speed:float = 1.0

var zoom_offset:float = 20.0
var camera_focus:Node3D
@onready var camera_target:Node3D = $CameraTarget
@onready var camera:Camera3D = $Camera3D


func _ready():
	var _a = Signals.plane_focused.connect(self._on_plane_focused)
	var _b = Signals.plane_followed.connect(self._on_plane_followed)


func _physics_process(delta):
	handle_input()
	lerp_camera(delta)


func handle_input():
	var direction:Vector3 = Vector3.ZERO
	if Input.is_action_pressed("ui_down"):
		direction.z = 1
	if Input.is_action_pressed("ui_up"):
		direction.z = -1
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	
	if Input.is_action_pressed("scroll_in"):
		zoom_offset += scroll_speed
	elif Input.is_action_pressed("scroll_out"):
		zoom_offset -= scroll_speed
	
	zoom_offset = clamp(zoom_offset, Y_DISTANCE_MIN, Y_DISTANCE_MAX)
	
	if direction != Vector3.ZERO:
		camera_focus = null
		camera_target.global_transform.origin += direction.normalized() * target_speed
	
	if is_instance_valid(camera_focus):
		camera_target.global_transform.origin = camera_focus.global_transform.origin


func lerp_camera(delta):
	var origin = camera.global_transform.origin
	var target = camera_focus.global_transform.origin if is_instance_valid(camera_focus) else  camera_target.global_transform.origin
	
	camera.global_transform.origin = Vector3(
		lerp(origin.x, target.x, camera_speed * delta),
		lerp(origin.y, target.y + zoom_offset, camera_speed * delta),
		lerp(origin.z, target.z, camera_speed * delta)
	)


func _on_plane_focused(plane):
	pass


func _on_plane_followed(plane):
	camera_focus = plane
