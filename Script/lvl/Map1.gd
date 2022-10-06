extends Node2D

export var generat = false

export var sistem = [false, false, false, false, false]

func _ready():
	if generat == false and(get_tree().network_peer == null or get_tree().is_network_server()):
		generat = true
		$TileMap.tiles = $TileMap.registration()
		
		$TileMap.generate(500, 100)
		for i in [{"copper": 0.4}, {"details": 0.4}, {"moss": 0.4}, {"ice": 0.4}, {"iron": 0.4}]:
			$TileMap.ore($TileMap.tiles, i, 500, 100)
		
		var manual = [
			[
				{"position": {"mode": 1, "value": Vector2(10, 0)}},
				{"tile": {"mode": 0, "shift": Vector2(0, 0), "value": {"tile_name": "ground"}}}, 
				{"tile": {"mode": 0, "shift": Vector2(-3, -3), "value": false}},
				{"tile": {"mode": 0, "shift": Vector2(3, -3), "value": false}},
				{"tile": {"mode": 0, "shift": Vector2(0, -3), "value": false}}
			], 
			[
				{"tile": {"shift": Vector2(-3, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(-2, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(-1, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				
				{"tile": {"shift": Vector2(0, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				
				{"tile": {"shift": Vector2(1, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(2, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(3, -4), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				
				{"tile": {"shift": Vector2(-3, -3), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(3, -3), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				
				
				{"tile": {"shift": Vector2(-3, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(-2, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(-1, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(0, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(1, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(2, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				{"tile": {"shift": Vector2(3, 0), "dat": {"tile_name": {"operation": 0, "value": "wall"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}}}},
				
				{"tile": {"shift": Vector2(0, -1), "dat": {"tile_name": {"operation": 0, "value": "chest"}, "autotile_coord": {"operation": 0, "value": Vector2(2, 0)}, "instruction": {"operation": 0, "value": [[{}, {"item": "diskette", "animation": {"event": 1, "frames": ["res://Texture/Other/Items/Diskette/broken.png"]}, "id_disket": 5}, {}]]}}}},
				
				{"tile_clear": {"shift": Vector2(-3, -1)}},
				{"tile_clear": {"shift": Vector2(-2, -1)}},
				{"tile_clear": {"shift": Vector2(-1, -1)}},
				{"tile_clear": {"shift": Vector2(1, -1)}},
				{"tile_clear": {"shift": Vector2(2, -1)}},
				{"tile_clear": {"shift": Vector2(3, -1)}},
				
				{"tile_clear": {"shift": Vector2(-3, -2)}},
				{"tile_clear": {"shift": Vector2(-2, -2)}},
				{"tile_clear": {"shift": Vector2(-1, -2)}},
				{"tile_clear": {"shift": Vector2(0, -2)}},
				{"tile_clear": {"shift": Vector2(1, -2)}},
				{"tile_clear": {"shift": Vector2(2, -2)}},
				{"tile_clear": {"shift": Vector2(3, -2)}},
				
				{"tile_clear": {"shift": Vector2(-2, -3)}},
				{"tile_clear": {"shift": Vector2(-1, -3)}},
				{"tile_clear": {"shift": Vector2(0, -3)}},
				{"tile_clear": {"shift": Vector2(1, -3)}},
				{"tile_clear": {"shift": Vector2(2, -3)}},
			]
		]
		
		$TileMap.tiles = $TileMap.structure($TileMap.tiles, manual, 1)
		
		$TileMap.render()

func _process(delta):
	if get_node_or_null("Player"):
		if get_node("Player").global_position.y > 7000:
			if get_node("Player").has_method("show_died"):
				get_node("Player").show_died("Поглощён оболочкой")
			else:
				get_node("Player").global_position.y = 7000
