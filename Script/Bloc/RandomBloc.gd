extends RigidBody2D

var rand = RandomNumberGenerator.new()
onready var SD = get_node_or_null("/root/rootGame/Node/SettingData")
onready var TM = get_node_or_null("/root/rootGame/Node/TileMap")

export var item:String

export var range_to_on:int = 2

export var used_var = true
export var use_set_item = true

func _ready():
	if get_node_or_null("/root/rootGame/Node/TileMap") != null:
		get_node("/root/rootGame/Node/TileMap").connect("map_event", self, "to_on")
	$AnimationPlayer.connect("animation_finished", self, "animation_finished")
	$VisibilityEnabler2D.connect("screen_entered", self, "screen_entered")
	randomize()
	if get_tree().network_peer != null and get_tree().is_network_server() == false:
		rpc_id(1, "get_item", get_tree().get_network_unique_id())

func to_on(x, y):
	TM = get_node_or_null("/root/rootGame/Node/TileMap")
	if TM != null:
		var local_position = TM.to_local(global_position)
		var map_position = TM.world_to_map(local_position)
		var difference = Vector2(x - map_position.x, y - map_position.y)
		if range_to_on >= difference.x and (range_to_on*-1) <= difference.x:
			if range_to_on >= difference.y and (range_to_on*-1) <= difference.y:
				self.sleeping = false

func use(user, _id):
	if used_var == true:
		used_var = false
		user.edit_items(item, 1)
		$AnimationPlayer.play("sabral")
		self.rpc("used")

remote func used():
	used_var = false
	$AnimationPlayer.play("sabral")

func spavn():
	for i in range(SD.random.size()):
		var rand_count:int
		for l in range(SD.random.size()):
			if l >= i:
				rand_count += SD.random[l]["creature"]
		rand_count = round(rand_count + (SD.random.size() - i))
		rand.randomize()
		var rand_result = rand.randi_range(1, rand_count)
		print(rand_result)
		if rand_result <= SD.random[i]["creature"]:
			item = str(SD.random[i]["item"])
			$Label.text = str("Получено " + SD.random[i]["name_in_game"] + " +1")
			$Sprite.texture = load(SD.random[i]["texture"])
			break
	if item == null:
		spavn()

func screen_entered():
	if item == null and get_node_or_null("/root/editmap") == null and use_set_item == true:
		spavn()
		if get_tree().network_peer != null:
			rpc("synchronization", item)

remote func synchronization(item_s):
	if item_s != null:
		for k in SD.items:
			if SD.get_node("ItemData").get(k)["item"] == item_s:
				$Sprite.texture = load(SD.get_node("ItemData").get(k)["animation"]["frames"][0])
				item = str(SD.get_node("ItemData").get(k)["item"])
				$Label.text = str("Получено " + SD.get_node("ItemData").get(k)["name_in_game"] + " +1")
				break
			else:
				$Sprite.texture = load("res://Tecture/Modeli/no_texture.png")

remote func get_item(id):
	if get_tree().network_peer != null:
		rpc_id(id, "synchronization", item)

func animation_finished(_anim_name):
	queue_free()
