extends Node2D


onready var htmpl=$htmpl
onready var vlst=$cc/vm/sx/vlst

func _ready():
	sig.connect("undo_reload",self,"set_list")


func _set_litem(item,itype):
	var hl=htmpl.duplicate()
	hl.show()
	if itype=="LINE":
		hl.get_node("lx").text="Line: "+str(item.get_point_count())
	elif itype=="TEXT":
		hl.get_node("lx").text="Text: "+str(item.text.substr(0,16))
	
	hl.get_node("bxhide").connect("pressed",self,"_onbxhide",[item])
	hl.get_node("bxdel").connect("pressed",self,"_onbxdel",[item])
	vlst.add_child(hl)


func _clear_list():
	for n in vlst.get_children():
		vlst.remove_child(n)
		n.queue_free()

	
func set_list(lst):
	_clear_list()
	var px=lst[0]
	var lx=lst[1]
	#print("> ",px," ",lx)
	var cnt=0
	if typeof(px)==typeof([]):
		for n in px:
			if n.get_point_count()>0:
				_set_litem(n,"LINE")
				cnt+=1
	cnt=0
	if typeof(lx)==typeof([]):
		for n in lx:
			_set_litem(n,"TEXT")
			cnt+=1


func _onbxhide(line,hl=""):
	sig.emit_signal("undo_action",{"obj":line,"act":"hide"})

func _onbxdel(line):
	sig.emit_signal("undo_action",{"obj":line,"act":"del"})

func _on_clsbtn_pressed():
	queue_free()
