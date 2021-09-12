extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _player_connected(id: int) -> void:
	print("_player_connected", id)
	go_to_game()

func _player_disconnected(id: int) -> void:
	print("_player_disconnected", id)
	go_to_lobby()

func _connected_ok() -> void:
	print("_connected_ok")
	go_to_game()

func _connected_fail() -> void:
	print("_connected_fail")

func _server_disconnected() -> void:
	print("_server_disconnected")
	go_to_lobby()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func go_to_game() -> void:
	get_tree().change_scene("res://Game.tscn")

func go_to_lobby() -> void:
	get_tree().change_scene("res://Lobby.tscn")

func _on_ButtonSingle_pressed():
	go_to_game()


func _on_ButtonHost_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(6969, 2)
	get_tree().set_network_peer(peer)
	$ipDisplay.text = get_ipv4_adresses_list()

func get_ipv4_adresses_list() -> String:
	var string = ''
	var regex = RegEx.new()
	regex.compile("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$")
	for ip in IP.get_local_addresses():
		if ip != "127.0.0.1" && regex.search(ip):
			string += ip + "\n"
	
	return string

func _on_ButtonJoin_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client($ipInput.text, 6969)
	get_tree().set_network_peer(peer)
