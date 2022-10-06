extends Node2D

export var Put = ""

func _process(_delta):
	if $RayCast2D.is_colliding() and Put != "":
		get_tree().change_scene(Put)
