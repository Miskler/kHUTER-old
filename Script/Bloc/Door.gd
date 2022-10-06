extends Area2D

onready var body = $Body/CollisionShape2D
onready var obstacle_detector: Area2D = $ObstacleDetector

var closed = true

func _ready():
	body = get_node("Body/CollisionShape2D")
	obstacle_detector = get_node("ObstacleDetector")
	print("Body: ", body)

func use(_user, _id):
	if closed == true:
		body.disabled = true
		$ColorRect.hide()
		$LightOccluder2D.hide()
		$ColorRect2.show()
		closed = false
	elif closed == false:
		for obstacle_body in obstacle_detector.get_overlapping_bodies():
			if obstacle_body.get("stopping_gates"):
				return
		body.disabled = false
		$ColorRect.show()
		$LightOccluder2D.show()
		$ColorRect2.hide()
		closed = true
	
	$".".rpc("event_door", closed)

remote func event_door(cl):
	print("Дверь обновилась")
	closed = cl
	if cl == false:
		body.disabled = true
		$ColorRect.hide()
		$LightOccluder2D.hide()
		$ColorRect2.show()
	elif cl == true:
		body.disabled = false
		$ColorRect.show()
		$LightOccluder2D.show()
		$ColorRect2.hide()
