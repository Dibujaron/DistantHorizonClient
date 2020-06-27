extends Node2D

export var socket_url = "ws://23.254.142.198:25611/ws/"
#export var socket_url = "ws://localhost:25611/ws/"
export (NodePath) var space_path
onready var space = get_node(space_path)

var _client = WebSocketClient.new()
var connected = false
func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	print("attempting to connect to ", socket_url, "...")
	_client.connect_to_url(socket_url)

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	print("Connection established to server ", socket_url, ".")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_client.disconnect_from_host(1000, "game closed")
		
func _on_data():
	var message_str = read_message()
	var parse_result = JSON.parse(message_str)
	if parse_result.error == OK:
		var json = parse_result.result
		var message_type = json["message_type"]
		if message_type == "world_state":
			get_parent().receive_world_update(json)
		elif message_type == "ships_initial_state":
			get_parent().receive_initial_ships(json)
		elif message_type == "ship_inputs":
			get_parent().receive_ship_inputs_update(json)
		elif message_type == "ship_heartbeats":
			get_parent().receive_ship_heartbeats(json)
		elif message_type == "trade_menu_info":
			get_parent().receive_trade_menu_info(json)
		elif message_type == "trade_menu_close":
			get_parent().receive_trade_menu_close(json)
		elif message_type == "ship_docked":
			get_parent().receive_ship_docked(json)
		elif message_type == "ship_undocked":
			get_parent().receive_ship_undocked(json)
	else:
		print(parse_result.error_string)

func purchase_from_station(commodity_name, quantity):
	var dict = {}
	print("bb purchasing from station")
	dict["message_type"] = "purchase_from_station"
	dict["commodity_name"] = commodity_name
	dict["quantity"] = quantity
	print("cc")
	send_message(JSON.print(dict))
	print("dd")
	
func sell_to_station(commodity_name, quantity):
	var dict = {}
	dict["message_type"] = "sell_to_station"
	dict["commodity_name"] = commodity_name
	dict["quantity"] = quantity
	send_message(JSON.print(dict))
	
func undock():
	var dict = {}
	dict["message_type"] = "undock"
	send_message(JSON.print(dict))
	
func send_message(message):
	var err = _client.get_peer(1).put_packet(str(message).to_utf8())
	
func _process(delta):
	_client.poll()
	
func read_message():
	return _client.get_peer(1).get_packet().get_string_from_utf8()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
