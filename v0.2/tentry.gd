extends Control

var sticky=true

#func _ready():
#	rect_size=Vector2(240,100)

func _input(event):
	if event is InputEventMouseMotion and sticky:
		var mp=get_global_mouse_position()
		set_position(mp)
	if event is InputEventMouseButton:
		sticky=false


func _on_bcancel_pressed():
	queue_free()


func _on_bok_pressed():
	var tmesg=$v/tedit.text
	sig.emit_signal("tentry",{"act":"ok","msg":tmesg})
