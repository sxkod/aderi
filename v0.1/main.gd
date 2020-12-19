extends Control


# TODO
# xport img
# line width
# mouse accuracy
#


var imgtypes=["jpg","JPG","png","PNG",]
var drawing=false
var pencils=[]
var labels=[]
var pncl
var curdir
var curimg
var curpage=0
var curimgs=[]
var iassoc={}

var tentryi
var ccolstyle

const pgsize=45

onready var fbx=$pc/hmain/vcr/fbscrl/fbx
onready var cnvs=$pc/hmain/vcl/iscrl/vx/imgrect
onready var colpx=$pc/hmain/ColorPicker
onready var iconspc=$pc/hmain/vcl/iscrl/vx/iconspc
onready var sysmsg=$pc/hmain/vcl/btnsetl/sysmsg
onready var vprt=$pc/hmain/vcl/iscrl/vx/vp
onready var lthick=$pc/hmain/vcl/btnsetl/lthick

func _ready():
	sig.connect("tentry",self,"_on_tentry")
	ccolstyle=StyleBoxFlat.new()
	ccolstyle.set_bg_color(Color(1,1,1,1))
	

func _input(event):
	if Input.is_action_just_pressed("draw"):
		if not _inside_cnvs(event):
			return

		drawing=true
		pncl=Line2D.new()
		pncl.default_color=colpx.color
		pncl.width=lthick.value
		pncl.show()
		cnvs.add_child(pncl)
		pencils.append(pncl)
	elif Input.is_action_just_released("draw"):
		drawing=false
	if event is InputEventMouseMotion and drawing and pncl:
		var cpos=event.position
		cpos.x-=cnvs.rect_global_position.x 
		cpos.y-=cnvs.rect_global_position.y
		pncl.add_point(cpos)

		
func _inside_cnvs(event):
	var epx=event.position
	var tl=cnvs.rect_position
	var br=cnvs.rect_size
	if epx.x>tl.x and epx.y>tl.y:
		if epx.x<tl.x+br.x and epx.y<tl.y+br.y:
			return true
		else:
			return false
	else:
		return false

func _list_files(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	return files

func _is_image_file(fname):
	if fname.get_extension() in imgtypes:
		return true
	else:
		return false

func _on_FileDialog_dir_selected(dir):
	curdir=dir
	var flist=_list_files(dir)
	flist.sort()
	curimgs=[]
	for n in flist:
		if _is_image_file(n):
			curimgs.append(n)
	_sane_dirs()
	_update_fbrowser()
	_update_iconspc(0)
	
func _sane_dirs():
	var dx=Directory.new()
	if dx.dir_exists(curdir+"/.aderi"):
		pass
	else:
		var ret=dx.make_dir(curdir+"/.aderi")
		if ret==0:
			_sysmsg("Created .aderi")
		else:
			_sysmsg("Unable to create .aderi there")

func _update_fbrowser():
	for n in curimgs:
		fbx.add_item(n,load(curdir+"/"+n))

func _clear_iconspc():
	var vx=iconspc.get_node("vx")
	for n in vx.get_children():
		if n.name!="hx" and n.name!="hnav":
			vx.remove_child(n)
			n.queue_free()

func _update_iconspc(pnum):
	_clear_iconspc()
	curpage=pnum
	var locimgs
	if curimgs.size()<pgsize:
		locimgs=curimgs
	else:
		locimgs=curimgs.slice(pnum*pgsize,(pnum+1*pgsize))

	var cnt=0

	var curhbx=iconspc.get_node("vx/hx").duplicate()
	curhbx.show()
	iconspc.get_node("vx").add_child(curhbx)
	for n in locimgs:
		if cnt<=9:
			cnt+=1
		else:
			cnt=0
			curhbx=iconspc.get_node("vx/hx").duplicate()
			curhbx.show()
			iconspc.get_node("vx").add_child(curhbx)

		var lbx=iconspc.get_node("vx/hx/bx").duplicate()
		lbx.show()
		_tex_button(lbx,curdir+"/"+n)
		lbx.hint_tooltip=n
		lbx.connect("pressed",self,"_load_imgrect",[n])
		curhbx.add_child(lbx)


func _sysmsg(mesg):
	sysmsg.text=mesg

func _tex_button(btn,tname):
	var img = Image.new()
	img.load(tname)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	btn.texture_normal=tex

func _on_Open_pressed():
	$FileDialog.show()


func _on_Color_pressed():
	if colpx.visible:
		colpx.hide()
	else:
		colpx.show()
	


func _clear_pencils():
	for n in pencils:
		cnvs.remove_child(n)
		n.queue_free()
	pencils=[]

func _clear_labels():
	for n in labels:
		cnvs.remove_child(n)
		n.queue_free()
	labels=[]

func _load_imgrect(fxname):
	_save_assoc()
	_clear_pencils()
	_clear_labels()
	curimg=fxname

	var fname=curdir+"/"+fxname
	var img = Image.new()
	img.load(fname)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	cnvs.texture=tex
	
	_load_assoc()
	cnvs.show()
	iconspc.hide()


func _pva2arr(pva):
	var res=[]
	for n in pva:
		res.append([n[0],n[1]])
	return res

func _arr2pva(arr):
	var pva=PoolVector2Array()
	for n in arr:
		pva.append(Vector2(n[0],n[1]))
	return pva

func _save_assoc():
	if not curimg:
		return
	var idata={}
	var cnt=0

	for n in pencils:
		if typeof(n)==typeof(Line2D.new()):
			var tmp={}
			tmp["type"]="Line2D"
			tmp["points"]=_pva2arr(n.get_points())
			var dcol=n.default_color
			tmp["default_color"]=[dcol[0],dcol[1],dcol[2],dcol[3]]
			tmp["width"]=n.width
			idata[cnt]=tmp
			cnt+=1
	
	for n in labels:
		if typeof(n)==typeof(Label.new()):
			var tmp={}
			tmp["type"]="Label"
			tmp["text"]=n.text 
			var dcol=n.get("custom_colors/font_color") 

			if dcol:
				tmp["color"]=[dcol[0],dcol[1],dcol[2],dcol[3]]

			tmp["pos"]=[n.get_position().x,n.get_position().y]
			idata[cnt]=tmp
			cnt+=1
			
	if idata:
		var fout=File.new()
		var ret=fout.open(curdir+"/.aderi/"+curimg+".adt",File.WRITE)
		if ret==0:
			var sx=to_json(idata)
			fout.store_string(sx)
			fout.close()

func _load_assoc():
	if not curimg:
		return
	var fxin=File.new()
	var ret=fxin.open(curdir+"/.aderi/"+curimg+".adt",File.READ)

	if ret!=0:
		_sysmsg("No "+curimg+".adt found")
		return

	var sx=fxin.get_as_text()
	fxin.close()
	var px=parse_json(sx)

	if typeof(px)!=typeof({}):
		_sysmsg("Loaded data not a dict")
		return
		
	for n in px:
		if typeof(px[n])==typeof({}) and "type" in px[n] and px[n]["type"]=="Line2D":
			var lx=Line2D.new()

			if "default_color" in px[n]:
				var dcol=px[n]["default_color"]
				if typeof(dcol)==typeof([]) and dcol.size()==4:
					lx.default_color=Color(dcol[0],dcol[1],dcol[2],dcol[3])

			if "width" in px[n]:
				lx.width=px[n]["width"]

			if "points" in px[n] and typeof(px[n]["points"])==typeof([]):
				lx.set_points(_arr2pva(px[n]["points"]))

			cnvs.add_child(lx)
			pencils.append(lx)

		if typeof(px[n])==typeof({}) and "type" in px[n] and px[n]["type"]=="Label":
			var lx=Label.new()

			if "text" in px[n]:
				lx.text=px[n]["text"]
			
			if "color" in px[n] and typeof(px[n]["color"])==typeof([]) and px[n]["color"].size()==4:
				var lcolor=Color(px[n]["color"][0],px[n]["color"][1],px[n]["color"][2],px[n]["color"][3])
				lx.set("custom_colors/font_color",lcolor) 
			if "pos" in px[n] and typeof(px[n]["pos"])==typeof([]):
				lx.set_position(Vector2(px[n]["pos"][0],px[n]["pos"][1]))
			labels.append(lx)
			cnvs.add_child(lx)

func _clear_assoc(fname):
	pass


func _on_fbx_item_selected(index):
	var fxname=fbx.get_item_text(index)
	if not fxname:
		return
	_load_imgrect(fxname)


func _on_ColorPicker_gui_input(event):
	if event is InputEventMouseButton:
		colpx.hide()
		ccolstyle.set_bg_color(colpx.color)
		$pc/hmain/vcl/btnsetl/ccol.set("custom_styles/panel", ccolstyle)
		
func _on_Files_pressed():
	if not curdir:
		_sysmsg("Open an images folder first")
		return
	iconspc.show()
	cnvs.hide()


func _on_Panel_pressed():
	if $hmain/vcr.visible:
		$hmain/vcr.hide()
	else:
		$hmain/vcr.show()


func _on_Save_pressed():
	_save_assoc()

func _on_Clear_pressed():
	_clear_pencils()
	_clear_labels()

func _on_Text_pressed():
	if not curimg:
		_sysmsg("Open an images folder first")
		return
	var tentry=load("res://tentry.tscn")
	if tentry:
		tentryi=tentry.instance()
	if tentryi:
		tentryi.rect_size=Vector2(240,100)
		add_child(tentryi)


func _on_tentry(tdata):
	if not tentryi:
		return
	var pos=tentryi.get_position()
	tentryi.queue_free()
	var lbx=Label.new()
	if typeof(tdata)==typeof({}) and "msg" in tdata:
		lbx.text=tdata["msg"]
		lbx.set("custom_colors/font_color",colpx.color) 
		cnvs.add_child(lbx)
		lbx.set_position(pos)
		labels.append(lbx)
	
	


func _on_prev_pressed():
	if curpage>0:
		curpage-=1
		_update_iconspc(curpage)



func _on_next_pressed():
	if curimgs.size()<pgsize:
		return
	if curpage*pgsize<curimgs.size():
		curpage+=1
		_update_iconspc(curpage)


func _on_Exprt_pressed():
	var cx=cnvs.get_viewport().get_texture().get_data()
	if not cx:
		_sysmsg("Failed to get imgdata ")
		return
	cx.flip_y()
	var fxname=curimg.get_basename()
	if not fxname:
		_sysmsg("Failed to get basename ")
		return
	
	fxname+="_aderi_exp.png"
	
	cx.save_png(curdir+"/"+fxname)
	
