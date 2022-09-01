extends Control


var plane

onready var border:Panel = $Border
onready var call_sign_label:Label = get_node("%CallSign")
onready var click_timer:Timer = $ClickTimer


func _ready():
	call_sign_label.text = plane.call_sign
	
	var _a = Signals.connect("plane_focused", self, "_on_plane_focused_global")
	var _b = Signals.connect("plane_landed", self, "_on_plane_landed_global")


func _on_plane_focused_global(other):
	if plane != other:
		border.hide()
	else:
		border.show()


func _on_plane_landed_global(other):
	if other == plane: queue_free()


func _on_View_pressed():
	plane.focused = !plane.focused
	if plane.focused: border.show()
	else: border.hide()
	
	Signals.emit_signal("plane_focused", plane if plane.focused else null)


func _on_PlaneAvatar_mouse_entered():
	plane.hovered = true
	Signals.emit_signal("plane_hovered", plane)


func _on_PlaneAvatar_mouse_exited():
	plane.hovered = false
	Signals.emit_signal("plane_hovered", null)


func _on_PlaneAvatar_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if click_timer.is_stopped():
				# Single Click
				click_timer.start()
			else:
				# Double Click
				Signals.emit_signal("plane_followed", plane)
				click_timer.stop()


func _on_ClickTimer_timeout():
	if plane.hovered: plane.focused = !plane.focused
	Signals.emit_signal("plane_focused", plane if plane.focused else null)
