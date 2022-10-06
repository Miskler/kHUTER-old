extends Area2D

onready var body = $Body/Shape
onready var obstacle_detector: Area2D = $ObstacleDetector

var closed = true

func use(_user):
	if closed:
		body.disabled = true
		$ColorRect.hide()
		$LightOccluder2D.hide()
		closed = false
	else:
		for obstacle_body in obstacle_detector.get_overlapping_bodies():
			if obstacle_body.get("stopping_gates"):
				return
		body.disabled = false
		$ColorRect.show()
		$LightOccluder2D.show()
		closed = true
