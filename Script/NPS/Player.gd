extends KinematicBody2D

onready var SD = get_node("/root/rootGame/Node/SettingData")

export var clutches:int

export var speed = Vector2(20, 520)

var gan_on = null

export var vec = Vector2()
export var Floor = Vector2(0,-1)

var well_being = {
	"hunger": 20, #Максимум 20
	"health": 100, #Максимум 100
	"thirst": 0.0 #Максимум 2.0
}

export var player_settings = {
	"disable_physics": false,
	"immortal": false,
	"invisible": false,
	"jumping": true,
	"itembar": true,
	"visible_battery": true,
	"visible_health": true,
	"visible_heating": true,
	"invisibility_to_players": false,
}


func _ready():
	setting_event()
	
	$Timer.connect("timeout", self, "event")
	$hunger.connect("timeout", self, "hunger")
	$thirst.connect("timeout", self, "thirst")
	
	clutches = SD.map_settings["number_of_clutches"]
	$thirst.wait_time = SD.map_settings["dehumidification_frequency"]
	
	if SD.map_settings["taking_away_hunger"] > 0: 
		$thirst.wait_time = SD.map_settings["dehumidification_frequency"]
		$thirst.start()
	if SD.map_settings["dehumidification_frequency"] > 0: 
		$hunger.wait_time = SD.map_settings["taking_away_hunger"]
		$hunger.start()
	
	$Camera2D/interface.slots_off_and_on(0, false)
	$Camera2D/interface.slots_off_and_on(1, false)
	$Camera2D/interface.slots_off_and_on(2, false)
	$Camera2D/interface.slots_off_and_on(3, false)
	$Camera2D/interface.slots_off_and_on(3, true)
	

func _input(event):
	setting_event()
	
	if event.is_action_pressed("OpenInvetori") and $Camera2D/interface/died.visible == false and $Camera2D/interface/dialogue.visible == false and $Camera2D/interface/chat.visible == false:
		if $Camera2D/interface/inventory.visible == false:
			show_inventory()
		else:
			show_main()
	elif event.is_action_pressed("esc") and $Camera2D/interface/died.visible == false and $Camera2D/interface/chat.visible == false:
		if $Camera2D/interface/menu.visible == false:
			show_menu()
		else:
			show_main()
	elif event.is_action_pressed("enter"):
		if $Camera2D/interface/chat.visible == false:
			show_chat()
		else:
			hide_chat()
	
	if SD.map_settings["taking_away_hunger"] != $hunger.wait_time:
		$hunger.wait_time = clamp(SD.map_settings["taking_away_hunger"], 1, 999999999)
		if SD.map_settings["taking_away_hunger"] > 0: $hunger.start()
		else: $hunger.stop()
	if SD.map_settings["dehumidification_frequency"] != $thirst.wait_time:
		$thirst.wait_time = clamp(SD.map_settings["dehumidification_frequency"], 1, 999999999)
		if SD.map_settings["dehumidification_frequency"] > 0: $thirst.start()
		else: $thirst.stop()

func setting_event():
	if player_settings["disable_physics"] == true:
		$CollisionShape2D.disabled = true
		$sat_down.disabled = true
	
	$Camera2D/interface/Battery.visible = player_settings["visible_battery"]
	$Camera2D/interface/main/battery.visible = player_settings["visible_battery"]
	$Camera2D/interface/main/health.visible = player_settings["visible_health"]
	$Camera2D/interface/main/heating.visible = player_settings["visible_heating"]
	
	$Camera2D/interface/main/HBoxContainer.visible = player_settings["itembar"]
	$Node2D.visible = not player_settings["invisible"]
	$Anim.visible = not player_settings["invisible"]

func _process(_delta):
	weapon_turn()
	event_gan()
	shoot()

func _physics_process(_delta):
	if $Camera2D/interface/died.visible == false and player_settings["disable_physics"] == false:
		movement()
		vec = move_and_slide(vec, Floor, true)

func event():
	if get_tree().network_peer != null:
		var mode
		if $Node2D.position.y == -9: mode = false
		else: mode = true
		get_node("/root/rootGame").rpc("event_state", "/root/rootGame/Node/" + str(get_tree().get_network_unique_id()), [get_tree().get_network_unique_id(), global_position, $Node2D.rotation_degrees, gan_on, $Node2D/Sprite.flip_v, $Anim.animation, $Anim.flip_h, mode, player_settings["invisibility_to_players"]])

func movement():
	if is_on_floor() and Input.is_action_pressed("a") and Input.is_action_pressed("d") and $Camera2D/interface/chat.visible == false:
		if vec.x > 30:
			vec.x -= 30
		elif vec.x < -30:
			vec.x += 30
		else:
			vec.x = 0
	elif Input.is_action_pressed("a") and $Camera2D/interface/main.visible == true and $Camera2D/interface/chat.visible == false:
		if is_on_floor():
			vec.x -= speed.x
			$Anim.play("run")
		else:
			vec.x -= speed.x/2
		$Anim.flip_h = true
	elif Input.is_action_pressed("d") and $Camera2D/interface/main.visible == true and $Camera2D/interface/chat.visible == false:
		if is_on_floor():
			vec.x += speed.x
			$Anim.play("run")
		else:
			vec.x += speed.x/2
		$Anim.flip_h = false
	else:
		if is_on_floor():
			if vec.x > 30:
				vec.x -= 30
			elif vec.x < -30:
				vec.x += 30
			else:
				vec.x = 0
	
	if Input.is_action_pressed("w") and player_settings["jumping"] == true and is_on_floor() and $Camera2D/interface/main.visible == true and $Camera2D/interface/chat.visible == false:
		vec.y -= speed.y
		$Anim.play("jump")
	elif Input.is_action_just_pressed("w") and player_settings["jumping"] == true and is_on_wall() and clutches > 0 and $Camera2D/interface/main.visible == true and $Camera2D/interface/chat.visible == false:
		clutches -= 1
		vec.y -= speed.y*1.5
		vec.y = clamp(vec.y, -550, 550)
		$Anim.play("jump")
	elif Input.is_action_pressed("s") and !is_on_floor() and $Camera2D/interface/main.visible == true and $Camera2D/interface/chat.visible == false:
		vec.y += speed.y/10
	
	if is_on_floor():
		clutches = SD.map_settings["number_of_clutches"]
	
	if vec.y > 1: $Anim.play("fall")
	elif vec.x == 0 and vec.y == 0: $Anim.play("idle")
	
	vec.y += speed.y/21
	
	vec.x = clamp(vec.x, -400, 400)
	vec.y = clamp(vec.y, -2000, 2000)
	
	if player_settings["disable_physics"] == false:
		if Input.is_action_pressed("s") and is_on_floor() and $Camera2D/interface/main.visible == true and $Camera2D/interface/chat.visible == false:
			vec.x = (vec.x+1) / 1.4
			$CollisionShape2D.disabled = true
			$sat_down.disabled = false
			$Anim.play("duck")
			#$Anim.rect_position.y = -8
			#$Anim.rect_size.y = 49
			$Node2D.position.y = 10
		else:
			$CollisionShape2D.disabled = false
			$sat_down.disabled = true
			#$Anim.rect_position.y = -41
			#$Anim.rect_size.y = 82
			$Node2D.position.y = -9

# Инвентарь

func get_items():
	return $Camera2D/interface/inventory.get_items()

# Самочувствие персонажа

func hunger():
	well_being["hunger"] -= 1
	well_being["hunger"] = clamp(well_being["hunger"], 0, 20)
	if well_being["hunger"] <= 0:
		well_being["health"] -= 20
		well_being["health"] = clamp(well_being["health"], 0, 100)
		if well_being["health"] <= 0:
			show_died("Голод")

func thirst():
	well_being["thirst"] += 0.1
	well_being["thirst"] = clamp(well_being["thirst"], 0.0, 2.0)
	if well_being["thirst"] >= 2.0:
		well_being["health"] -= 20
		well_being["health"] = clamp(well_being["health"], 0, 100)
		if well_being["health"] <= 0:
			show_died("Жажда")

# Оружие

func event_gan():
	var gan = $Camera2D/interface/clothes/Control/MainArmSlot/Texture.texture
	if gan != null:
		gan_on = gan.get_path()
		$Node2D/Sprite.show()
		$Node2D/Sprite.texture = load(gan_on)
	else:
		gan_on = null
		$Node2D/Sprite.hide()
		$Node2D/Sprite.texture = null

#Стрельба
func shoot():
	var gan = $Camera2D/interface/clothes.data_clothes["gan"][0].get("item")
	if $Camera2D/interface/MoveItem/HandSlot.significant_data.hash() != $Camera2D/interface/MoveItem/HandSlot.default_significant_data.hash(): return
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if Input.is_action_just_pressed("LBM") and $Camera2D/interface/MoveItem/HandSlot.significant_data.hash() == $Camera2D/interface/MoveItem/HandSlot.default_significant_data.hash() and $Camera2D/interface/main.visible == true and gan != null:
		if get_node_or_null("/root/rootGame/Node/SettingData/ItemLogical/" + str(gan)) == null:
			var bullet_name = $Camera2D/interface/clothes/Control/AdditionalArmSlot.significant_data.get("item")
			var gan_dat
			if gan != null: gan_dat = SD.get_node("ItemData").get(str(gan))
			
			var bullet_dat
			if bullet_name != null: bullet_dat = SD.get_node("ItemData").get(str(bullet_name))
			
			if gan_dat != null and(gan_dat["type"] == "sword" or bullet_name != null) and($Camera2D/interface/clothes.data_clothes["bullet"][0] in [null or true] or bullet_name in gan_dat.get("bullets_needed")):
				var dat = ["res://Tecture/Modeli/no_texture.png", 0, 0, 1000, false, 0] #текстура, урон, придяжение, скорость, режим пули
				
				if bullet_dat != null: dat[0] = bullet_dat.get("special_animation")
				if dat[0] == null: dat[0] = $Camera2D/interface/clothes/Control/AdditionalArmSlot/Texture.texture.get_path()
				
				if $Camera2D/interface/clothes/Control/AdditionalArmSlot/Texture.texture != null:
					dat[0] = $Camera2D/interface/clothes/Control/AdditionalArmSlot/Texture.texture.get_path()
				
				if gan_dat.get("output") != null: 
					dat[5] = gan_dat["output"]
					vec += Vector2(gan_dat["output"], 0).rotated($Node2D.rotation-3.1415926535)
				
				if bullet_dat == null: bullet_dat = {}
				var dop_dat = [gan_dat.get("number"), bullet_dat.get("number")]
				if not dop_dat[0] is int: dop_dat[0] = 0
				if not dop_dat[1] is int: dop_dat[1] = 0
				dat[1] = dop_dat[0] + dop_dat[1]
				
				if gan_dat.get("type") == "sword": 
					dat[4] = true
					dat[3] = 1
				
				get_node("/root/rootGame").create_bullet($Camera2D/interface/clothes.data_clothes["gan"], $Camera2D/interface/clothes.data_clothes["bullet"], $Node2D/Position2D.global_position, $Node2D.rotation, dat[0], dat[1], dat[2], dat[3], dat[4], dat[5], self)
				if get_tree().network_peer != null:
					get_node("/root/rootGame").rpc("create_bullet", $Camera2D/interface/clothes.data_clothes["gan"], $Camera2D/interface/clothes.data_clothes["bullet"], $Node2D/Position2D.global_position, $Node2D.rotation, dat[0], dat[1], dat[2], dat[3], dat[4], dat[5])
				
				$Camera2D/interface/clothes.take_away_the_bullet()
		elif get_node_or_null("/root/rootGame/Node/SettingData/ItemLogical/" + str(gan)).has_method("shoot"):
			get_node_or_null("/root/rootGame/Node/SettingData/ItemLogical/" + str(gan)).shoot($Camera2D/interface/clothes/Control/MainArmSlot, $Camera2D/interface/clothes/Control/AdditionalArmSlot, self)

func weapon_turn():
	$Node2D.look_at(get_global_mouse_position())
	if $Node2D.rotation_degrees > 360:
		$Node2D.rotation_degrees -= 360
	elif $Node2D.rotation_degrees < -360:
		$Node2D.rotation_degrees += 360
	
	if $Node2D.rotation_degrees > 90 or $Node2D.rotation_degrees < -90:
		$Node2D/Sprite.flip_v = true
	else:
		$Node2D/Sprite.flip_v = false

remote func damage(setting_bullet):
	if player_settings["immortal"] == false:
		var lvl_on = setting_bullet["damage"]
		var double = null
		
		if setting_bullet["gan"] != [{}, {}]:
			for i in SD.items:
				if i is Dictionary and i.get("item") == setting_bullet["gan"][0].get("item"):
					double = i["double_damage"]
			if setting_bullet["bullet"] != [{}, {}]:
				for i in SD.items:
					if i is Dictionary and i.get("item") == setting_bullet["bullet"][0].get("item"):
						double += i["double_damage"]
		
		if double is Dictionary and "player" in double:
			lvl_on = lvl_on * 2
		lvl_on = (lvl_on - ($Camera2D/interface/clothes.data_clothes["armor"] / 100))
		
		well_being["health"] -= lvl_on
		
		var armor = [$Camera2D/interface/clothes/Control/LegsSlot, $Camera2D/interface/clothes/Control/HeadSlot, $Camera2D/interface/clothes/Control/TorsoSlot]
		for i in armor:
			var dat = get_node_or_null("/root/rootGame/Node/SettingData/ItemLogical/" + var2str(i.significant_data.get("item")))
			if i.significant_data.get("item") != null and dat != null and dat.has_method("get_damage"):
				dat.get_damage(i, self, setting_bullet, lvl_on)
		
		if well_being["health"] <= 0:
			show_died("Убийство")
	else:
		return false

# Элементы интерфейса

func edit_items(item_s, quantity_s):
	$Camera2D/interface/inventory.edit_items(item_s, quantity_s)

func show_inventory():
	$Camera2D/interface/inventory.show()
	$Camera2D/interface/clothes.show()
	$Camera2D/interface/menu.hide()
	$Camera2D/interface/main.hide()
	
	$Camera2D/interface.slots_off_and_on(1, false)
	$Camera2D/interface.slots_off_and_on(3, false)
	$Camera2D/interface.slots_off_and_on(4, true)

func show_craft_menu():
	$Camera2D/interface/inventory.show()
	$Camera2D/interface/craft_menu.show()
	$Camera2D/interface/clothes.show()
	$Camera2D/interface/menu.hide()
	$Camera2D/interface/main.hide()
	
	$Camera2D/interface.slots_off_and_on(0, false)
	$Camera2D/interface.slots_off_and_on(1, false)
	$Camera2D/interface.slots_off_and_on(3, false)
	$Camera2D/interface.slots_off_and_on(4, true)

func show_chest(chest, name_var_data):
	$Camera2D/interface/chest.connect_chest(chest, name_var_data)
	$Camera2D/interface/inventory.show()
	$Camera2D/interface/chest.show()
	$Camera2D/interface/clothes.show()
	$Camera2D/interface/menu.hide()
	$Camera2D/interface/main.hide()
	
	$Camera2D/interface.slots_off_and_on(1, false)
	$Camera2D/interface.slots_off_and_on(2, false)
	$Camera2D/interface.slots_off_and_on(3, false)
	$Camera2D/interface.slots_off_and_on(4, true)

func show_main():
	$Camera2D/interface/main.show()
	$Camera2D/interface/inventory.hide()
	$Camera2D/interface/craft_menu.hide()
	$Camera2D/interface/clothes.hide()
	$Camera2D/interface/chest.hide()
	$Camera2D/interface/menu.hide()
	
	$Camera2D/interface.slots_off_and_on(0, true)
	$Camera2D/interface.slots_off_and_on(1, true)
	$Camera2D/interface.slots_off_and_on(2, true)
	$Camera2D/interface.slots_off_and_on(3, true)
	$Camera2D/interface.slots_off_and_on(4, false)

func show_dialogue(dialogue = null):
	$Camera2D/interface/main.hide()
	$Camera2D/interface/inventory.hide()
	$Camera2D/interface/craft_menu.hide()
	$Camera2D/interface/clothes.hide()
	$Camera2D/interface/chest.hide()
	$Camera2D/interface/menu.hide()
	$Camera2D/interface/dialogue.show()
	if dialogue is Dictionary:
		$Camera2D/interface/dialogue.read_dialogue(dialogue)
	else:
		$Camera2D/interface/dialogue.read_dialogue()
	
	$Camera2D/interface.slots_off_and_on(0, true)
	$Camera2D/interface.slots_off_and_on(1, true)
	$Camera2D/interface.slots_off_and_on(2, true)
	$Camera2D/interface.slots_off_and_on(3, true)
	$Camera2D/interface.slots_off_and_on(4, true)

func show_chat():
	if $Camera2D/interface/Control.rect_position.y == 0:
		$Camera2D/interface/Control/AnimationPlayer.play("def")
	$Camera2D/interface/chat.show()

func hide_chat():
	$Camera2D/interface/chat.hide()

func show_menu():
	$Camera2D/interface/main.hide()
	$Camera2D/interface/inventory.hide()
	$Camera2D/interface/craft_menu.hide()
	$Camera2D/interface/clothes.hide()
	$Camera2D/interface/chest.hide()
	$Camera2D/interface/menu.show()
	
	$Camera2D/interface.slots_off_and_on(0, true)
	$Camera2D/interface.slots_off_and_on(1, true)
	$Camera2D/interface.slots_off_and_on(2, true)
	$Camera2D/interface.slots_off_and_on(3, true)
	$Camera2D/interface.slots_off_and_on(4, true)

func show_died(cause):
	if $Camera2D/interface/died.visible == false:
		get_node("/root/rootGame").rpc("player_died", get_tree().get_network_unique_id())
		var died_text = "Игрок " + str(G.game_settings["player_name"]) + " умер по причине: " + str(cause) + "."
		get_node("/root/rootGame").sms(died_text)
		get_node("/root/rootGame").rpc("sms", died_text)
		G.live_player_roster.erase(get_tree().get_network_unique_id())
		$Camera2D/interface/died.died(cause)
		$Camera2D/interface/main.hide()
		$Camera2D/interface/inventory.hide()
		$Camera2D/interface/craft_menu.hide()
		$Camera2D/interface/clothes.hide()
		$Camera2D/interface/chest.hide()
		$Camera2D/interface/menu.hide()
		$Camera2D/interface/dialogue.hide()
		$Camera2D/interface/died.show()
		
		$Camera2D/interface.slots_off_and_on(0, false)
		$Camera2D/interface.slots_off_and_on(1, false)
		$Camera2D/interface.slots_off_and_on(2, false)
		$Camera2D/interface.slots_off_and_on(3, false)
		$Camera2D/interface.slots_off_and_on(4, false)
		
		var dat_items = $Camera2D/interface/inventory.get_items()
		
		dat_items.append([0, $Camera2D/interface/clothes/Control/HeadSlot.significant_data, $Camera2D/interface/clothes/Control/HeadSlot.insignificant_data])
		dat_items.append([0, $Camera2D/interface/clothes/Control/TorsoSlot.significant_data, $Camera2D/interface/clothes/Control/TorsoSlot.insignificant_data])
		dat_items.append([0, $Camera2D/interface/clothes/Control/LegsSlot.significant_data, $Camera2D/interface/clothes/Control/LegsSlot.insignificant_data])
		if $Camera2D/interface/clothes/Control/MainArmSlot.significant_data.hash() != $Camera2D/interface/clothes/Control/MainArmSlot.default_significant_data.hash():
			dat_items.append([0, $Camera2D/interface/clothes/Control/MainArmSlot.significant_data, $Camera2D/interface/clothes/Control/MainArmSlot.insignificant_data])
		if $Camera2D/interface/clothes/Control/AdditionalArmSlot.significant_data.hash() != $Camera2D/interface/clothes/Control/AdditionalArmSlot.default_significant_data.hash():
			dat_items.append([0, $Camera2D/interface/clothes/Control/AdditionalArmSlot.significant_data, $Camera2D/interface/clothes/Control/AdditionalArmSlot.insignificant_data])
		
		for i in dat_items:
			if i[1].size() > 0:
				var random_bloc = load("res://Sceni/item/ItemInWorld.scn").instance()
				
				var f_name = "SlotInWorld_" + str(rand_range(0, 1))
				
				random_bloc.get_node("SlotInWorld").significant_data = i[1]
				random_bloc.get_node("SlotInWorld").insignificant_data = i[2]
				
				random_bloc.global_position = global_position
				random_bloc.name = f_name
				
				$Camera2D/interface/MoveItem.rpc("put_item", i[1], i[2], global_position, f_name)
				
				get_node("/root/rootGame/Node").add_child(random_bloc)
		
		return true
	return false

# Эффекты для персонажа

func effect_hunger(lvl):
	well_being["hunger"] += lvl
	well_being["hunger"] = clamp(well_being["hunger"], 0, 20)

func effect_health(lvl):
	well_being["health"] += lvl
	if well_being["health"] <= 0:
		show_died("Убийство")

func effect_thirst(lvl):
	well_being["thirst"] += lvl
	well_being["thirst"] = clamp(well_being["thirst"], 0.0, 2.0)
	if well_being["thirst"] >= 2.0:
		well_being["health"] -= 20
		well_being["health"] = clamp(well_being["health"], 0, 100)
		if well_being["health"] <= 0:
			show_died("Жажда")
