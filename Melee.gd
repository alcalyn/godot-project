extends Node2D

var lanePosition: float
var units: Array = [[], []]

func init(_lanePosition: float):
	lanePosition = _lanePosition

func _process(_delta):
	position.x = lanePosition * 500

