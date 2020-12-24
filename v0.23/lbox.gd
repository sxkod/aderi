extends Node2D

onready var cpng = load("res://icons/clear.png")

func _ready():
	pass
	
	
func _update_bookmarks():
	var pdx=util._read_conf()
	if not typeof(pdx)==typeof({}):
		return
	if "bookmarks" in pdx:
		var bmx=pdx["bookmarks"]
		if typeof(bmx)==typeof([]):
			for n in bmx:
				$vx/sc/lx.add_icon_item(cpng)
				$vx/sc/lx.add_item(n)



func _on_lx_item_selected(index):
	if index%2==0:
		_remove_a_bookmark(index+1)
	else:
		var seldir=$vx/sc/lx.get_item_text(index)
		sig.emit_signal("bookmarksel",seldir)
	queue_free()

func _remove_a_bookmark(bidx):
	var bname=$vx/sc/lx.get_item_text(bidx)
	var pdx=util._read_conf()
	if not typeof(pdx)==typeof({}):
		return
	if "bookmarks" in pdx:
		if bname in pdx["bookmarks"]:
			var baindex=pdx["bookmarks"].find(bname)
			pdx["bookmarks"].remove(baindex)
			util._write_conf(pdx)



func _on_closebtn_pressed():
	queue_free()


func _on_OptionButton_item_selected(index):
	print(index)
	pass # Replace with function body.
