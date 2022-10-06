extends Area2D

export var play = []
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func use(user, _id):
	if $AnimatedSprite.animation in ["off", "stop"]:
		$AudioStreamPlayer2D2.stream_paused = false
		$AudioStreamPlayer2D.stream_paused = false
		$AnimatedSprite.play("play")
		if $AudioStreamPlayer2D.stream == null: set_stream()
	else:
		$AnimatedSprite.play("stop")
		$AudioStreamPlayer2D2.stream_paused = true
		$AudioStreamPlayer2D.stream_paused = true

func set_stream():
	if play.size() > 0:
		$AudioStreamPlayer2D.stream = load(play[rng.randi_range(0, play.size() - 1)])
	else: $AudioStreamPlayer2D.stream = null
