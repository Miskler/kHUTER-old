extends Area2D

var rand = RandomNumberGenerator.new()

func _ready():
	rand.randomize()
	var rand_result = round(rand.randi_range(1, 2))
	if rand_result == 1:
		$verst.texture = load("res://Tecture/Modeli/verstac_1.png")
	else:
		$verst.texture = load("res://Tecture/Modeli/verstac_2.png")

func use(user, _id):
	user.show_craft_menu()
