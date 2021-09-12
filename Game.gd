extends Node2D


var unitNextLane: int = -1
var timer: Timer = null


func _ready():
	for i in range(0, 5):
		var lane = preload("res://Lane.tscn").instance()
		
		lane.init(i)
		lane.set_name("lane" + str(i))
		lane.position.x = 50
		lane.position.y = i * 100 + 50
		
		add_child(lane)

	timer = Timer.new()
	add_child(timer)

	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.set_wait_time(1.0)
	timer.set_one_shot(false)
	timer.start()

func _on_Timer_timeout() -> void:
	if unitNextLane < 0:
		return
		
	get_node('lane' + str(unitNextLane)).spawn_unit()
	unitNextLane = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
