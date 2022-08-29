extends Spatial

const Y_DISTANCE:float = 20.0

var target_speed:float = 0.8
var camera_speed:float = 3.0

onready var camera_target:Spatial = $CameraTarget
onready var camera:Camera = $Camera


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
	
	camera_target.global_transform.origin += direction.normalized() * target_speed


func lerp_camera(delta):
	var origin = camera.global_transform.origin
	var target = camera_target.global_transform.origin
	
	camera.global_transform.origin = Vector3(
		lerp(origin.x, target.x, camera_speed * delta),
		lerp(origin.y, target.y + Y_DISTANCE, camera_speed * delta),
		lerp(origin.z, target.z, camera_speed * delta)
	)
