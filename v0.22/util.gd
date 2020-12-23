extends Node

var conf="user://aderi.conf"

func _read_conf():
	var fx=File.new()
	if not fx.file_exists(conf):
		return
	fx.open(conf,File.READ)
	var data=fx.get_as_text()
	fx.close()
	var pdx=parse_json(data)
	if not typeof(pdx)==typeof({}):
		return
	return pdx
	
func _write_conf(wdata):
	var pdx=_read_conf()
	if not typeof(pdx)==typeof({}):
		pdx={}
	for n in wdata:
		pdx[n]=wdata[n]

	var fx=File.new()
	fx.open(conf,File.WRITE)
	var pdxstr=to_json(pdx)
	fx.store_string(pdxstr)
	fx.close()
	
