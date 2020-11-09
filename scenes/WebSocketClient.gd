extends Node2D

export (NodePath) var space_path
onready var space = get_node(space_path)

var _client = WebSocketClient.new()
var connected = false

var outgoing_message_queue = []
var incoming_message_queue = []
func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	print("attempting to connect to ", Global.server_url(), "...")
	_client.connect_to_url(Global.server_url())

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	print("Connection established to server ", Global.server_url(), ".")
	var dict = {}
	var authenticated = Global.authenticated
	dict["message_type"] = "init"
	dict["authenticated"] = authenticated
	if authenticated:
		dict["client_key"] = Global.login_key
	send_json_message(dict)
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_client.disconnect_from_host(1000, "game closed")
		
func _process(delta):
	_client.poll()
	while not incoming_message_queue.empty():
		process_message(incoming_message_queue.pop_front())
	while not outgoing_message_queue.empty():
		send_json_message(outgoing_message_queue.pop_front())
		
func _on_data():
	var msg = read_json_message()
	if Global.request_batching:
		incoming_message_queue.push_back(msg)
	else:
		process_message(msg)
		
func process_message(json):
	var message_type = json["message_type"]
	if message_type == "world_state":
		get_parent().receive_world_update(json)
	elif message_type == "ship_inputs":
		get_parent().receive_ship_inputs_update(json)
	elif message_type == "ship_heartbeats":
		get_parent().receive_ship_heartbeats(json)
	elif message_type == "station_menu_info":
		get_parent().receive_station_menu_info(json)
	elif message_type == "station_menu_close":
		get_parent().receive_station_menu_close(json)
	elif message_type == "ship_docked":
		print("got ship docked.")
		get_parent().receive_ship_docked(json)
	elif message_type == "ship_undocked":
		print("got ship undocked.")
		get_parent().receive_ship_undocked(json)
	elif message_type == "ships_added":
		get_parent().receive_ships_added(json)
	elif message_type == "ships_removed":
		get_parent().receive_ships_removed(json)
	elif message_type == "chat":
		Global.get_chat_hud().receive_chat_message(json)

func queue_outgoing_message(msg_dict):
	var json_msg = JSON.print(msg_dict)
	if Global.request_batching:
		outgoing_message_queue.push_back(json_msg)
	else:
		send_json_message(json_msg)
	
func purchase_from_station(commodity_name, quantity):
	var dict = {}
	dict["message_type"] = "purchase_from_station"
	dict["commodity_name"] = commodity_name
	dict["quantity"] = quantity
	queue_outgoing_message(dict)

	
func sell_to_station(commodity_name, quantity):
	var dict = {}
	dict["message_type"] = "sell_to_station"
	dict["commodity_name"] = commodity_name
	dict["quantity"] = quantity
	queue_outgoing_message(dict)
	
func undock():
	var dict = {}
	dict["message_type"] = "undock"
	queue_outgoing_message(dict)
	
func send_chat_message(message):
	var dict = {}
	dict["message_type"] = "chat"
	dict["payload"] = message
	queue_outgoing_message(dict)
	
func send_json_message(json_message):
	var err = _client.get_peer(1).put_packet(str(json_message).to_utf8())
	
func read_json_message():
	var message_str = _client.get_peer(1).get_packet().get_string_from_utf8()
	var parse_result = JSON.parse(message_str)
	if parse_result.error == OK:
		return parse_result.result
	else:
		print(parse_result.error_string)
		return null


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
