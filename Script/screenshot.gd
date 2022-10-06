extends Node

var SCREENfile
export var file_prefix = ""

var _tag = ""
var _index = 0

func _ready():
	var dir = Directory.new()
	print(OS.get_system_dir(OS.SYSTEM_DIR_PICTURES))
	
	SCREENfile = str(OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)) + "/Huter"
	
	if not dir.dir_exists(SCREENfile):
		dir.make_dir_recursive(SCREENfile)
	
	dir.open(SCREENfile)
	
	if not SCREENfile[-1] == "/":
		SCREENfile += "/"
	if not file_prefix.empty():
		file_prefix += "_"
	set_process_input(true)

func _input(_event):
	if Input.is_action_just_pressed("F12"):
		make_screenshot()

func make_screenshot():
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	
	_update_tags()
	image.save_png("%s%s%s_%s-индекс.png" % [SCREENfile, file_prefix, _tag, _index])

func _update_tags():
	var time
	
	time = OS.get_datetime()
	time = "%s-%02d-%02d-%02d" % [time['year'], time['month'], time['day'], time['hour']]
	if (_tag == time): _index += 1
	else:
		_index = 0
	_tag = time
