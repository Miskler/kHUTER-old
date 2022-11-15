extends Node

#НОВЫЕ

var game_settings = {
	"version": "0.2.2",
	"boot_menu": true,
	"bad_graphics": false,
	"FPS": 60,
	"port": 7732,
	"player_name": "Player1234",
}

export var ways = {
	"main": "C:/Users/ПК/AppData/Roaming/Godot/app_userdata/Huter/SaveGame",
	"settings": "user://SaveGame/setting_data.json",
	"data_servers": "user://SaveGame/servers_data.json",
	"server": "127.0.0.1"#"5.44.41.50",
}

var player_roster = {}
var live_player_roster = {}


#СТАРЫЕ

var loadSCN

func _input(_event):
	if Input.is_action_just_pressed("FullScrin"):
		OS.window_fullscreen = not OS.window_fullscreen
	elif Input.is_action_just_pressed("F5"):
		save_game("быстрое-сохранение")

func remove_recursive(path):
	var directory = Directory.new()
	
	var error = directory.open(path)
	directory.list_dir_begin(true)
	var file_name = directory.get_next()
	while file_name != "":
		if directory.current_is_dir():
			remove_recursive(path + "/" + file_name)
		else:
			directory.remove(file_name)
		file_name = directory.get_next()
	
	directory.remove(path)

func typeto(variable, type:int = 0):
	match type:
		TYPE_BOOL:
			return bool(variable)
		TYPE_INT:
			return int(variable)
		TYPE_REAL:
			return float(variable)
		TYPE_STRING:
			return str(variable)
	return variable

func name_generate(standart_name:String, path:String):
	var node = get_node_or_null(path)
	if node != null:
		var out_name = standart_name+"_1"
		while node.get_node_or_null(out_name) != null:
			out_name = standart_name+"_"+str(randf()*1000000)
		return out_name
	return false

func comparison(one, two, mode:int = 0):
	mode = clamp(mode, -1, 1)
	if typeof(one) != typeof(two): return null
	
	var result
	if mode == -1: #one<two
		if one is Vector2:
			result = one.x < two.x and one.y < two.y
		else:
			result = one < two
	elif mode == 0: #one=two
		if one is Vector2:
			result = one.x == two.x and one.y == two.y
		else:
			result = one == two
	else: #one>two
		if one is Vector2:
			result = one.x > two.x and one.y > two.y
		else:
			result = one > two
	return result

func save_game(name_save):
	$map_packer.save_game(name_save)

remote func _player_connected(user_id, user_name):
	$map_packer.send_map(user_id, user_name)
