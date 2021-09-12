extends Node2D


var player: int
var lanePosition: float
var strength: int = 1
var laneWidth: float = 0.05

func init(_player: int):
	player = _player
	lanePosition = _player

	scale.x = 1 if _player == 0 else -1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
