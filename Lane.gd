extends Node2D


const UNIT_SPEED_COEF = 0.15
const LANE_DIMENSION = Rect2(0, 0, 500, 80)

var singleUnits = []
var melee = null
var index: int = -1

func init(_index: int) -> void:
	index = _index


func _draw():
	draw_rect(LANE_DIMENSION, Color(1, 1, 0, 0.2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for unit in singleUnits:
		var direction = 1 if unit.player == 0 else -1
		unit.lanePosition += UNIT_SPEED_COEF * direction * delta
	
	for unit in singleUnits:
		if unit.lanePosition < 0 || unit.lanePosition > 1:
			singleUnits.erase(unit)
			remove_child(unit)
			
	_check_melee_creation()
	_check_melee_join()
	_melee_move(delta)
	
	for unit in singleUnits:
		unit.position.x = unit.lanePosition * LANE_DIMENSION.size.x + LANE_DIMENSION.position.x


func _input(event):
	if event is InputEventMouseButton:
		var y = get_local_mouse_position().y
		if LANE_DIMENSION.has_point(get_local_mouse_position()):
			get_parent().unitNextLane = index


func spawn_unit() -> void:
	var player = 0 if get_tree().is_network_server() else 1
	_do_spawn_unit(player)
	rpc("_do_spawn_unit", player)


remote func _do_spawn_unit(player: int) -> void:
	var unit = preload("res://Unit.tscn").instance()
	unit.init(player)
	unit.position.y = LANE_DIMENSION.size.y / 2.0
	singleUnits.push_front(unit)
	add_child(unit)


func _check_melee_creation():
	if null != melee:
		return

	var farestUnit: Array = [null, null]
	
	for unit in singleUnits:
		if unit.player == 0 && (null == farestUnit[0] || unit.lanePosition > farestUnit[0].lanePosition):
			farestUnit[0] = unit

		if unit.player == 1 && (null == farestUnit[1] || unit.lanePosition < farestUnit[1].lanePosition):
			farestUnit[1] = unit
			
	if null == farestUnit[0] || null == farestUnit[1]:
		return
	
	if farestUnit[0].lanePosition < farestUnit[1].lanePosition:
		return
		
	melee = preload("res://Melee.tscn").instance()
	melee.init((farestUnit[0].lanePosition + farestUnit[1].lanePosition) / 2)
	melee.position.y = LANE_DIMENSION.size.y / 2.0
	
	add_child(melee)
	
	_unit_join_melee(farestUnit[0])
	_unit_join_melee(farestUnit[1])


func _unit_join_melee(unit) -> void:
	singleUnits.erase(unit)
	remove_child(unit)
	melee.add_child(unit)
	melee.units[unit.player].push_front(unit)
	
	unit.lanePosition = laneWidth(unit.player) * (-1 if unit.player == 0 else 1)
	unit.position.x = unit.lanePosition * LANE_DIMENSION.size.x
	unit.position.y = 0


func _check_melee_join():
	if null == melee:
		return
		
	var meleeLaneWidth: Array = [0.0, 0.0]
	
	for p in [0, 1]:
		for unit in melee.units[p]:
			meleeLaneWidth[p] += unit.laneWidth

	for unit in singleUnits:
		if unit.player == 0:
			if unit.lanePosition > (melee.lanePosition - meleeLaneWidth[0]):
				_unit_join_melee(unit)
		else:
			if unit.lanePosition < (melee.lanePosition + meleeLaneWidth[1]):
				_unit_join_melee(unit)


func _melee_move(delta):
	if null == melee:
		return

	var strength = [1, 1]
	
	for p in [0, 1]:
		for unit in melee.units[p]:
			strength[p] += unit.strength
	
	var winningPlayer = 0 if strength[0] > strength[1] else 1
	var meleeSpeed = 1.0 - float(min(strength[0], strength[1])) / float(max(strength[0], strength[1]))
	var meleeDirection = 1.0 if winningPlayer == 0 else -1.0
	
	melee.lanePosition += UNIT_SPEED_COEF * meleeSpeed * meleeDirection * delta
	
	for unit in melee.units[1 - winningPlayer]:
		var unitGlobalLanePosition = melee.lanePosition + unit.lanePosition
		if unitGlobalLanePosition > 1 || unitGlobalLanePosition < 0:
			melee.units[unit.player].erase(unit)
			melee.remove_child(unit)
	
	if melee.lanePosition < 0 || melee.lanePosition > 1:
		remove_child(melee)
		melee = null


func laneWidth(player) -> float:
	var meleeLaneWidth: float = 0
	for meleeUnit in melee.units[player]:
		meleeLaneWidth += meleeUnit.laneWidth
		
	return meleeLaneWidth
