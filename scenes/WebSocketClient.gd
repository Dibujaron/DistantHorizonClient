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
	var ws_url = "ws://" + Global.server_address() + "/ws/"
	print("attempting to connect to ", ws_url, "...")
	_client.connect_to_url(ws_url)

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(_proto = ""):
	print("Connection established to server ", Global.server_address(), ".")
	var dict = {}
	var authenticated = Global.authenticated
	dict["message_type"] = "init"
	dict["authenticated"] = authenticated
	if authenticated:
		dict["client_key"] = Global.login_key
		dict["actor_id"] = Global.actor_id
	print("sending initial websocket message to complete login.")
	send_json_message(dict)
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_client.disconnect_from_host(1000, "game closed")
		
func _process(_delta):
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
	elif message_type == "money_earned":
		get_parent().receive_money_earned(json)
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
	
func buy_ship(ship_class, ship_name, color1, color2):
	print("sending buy ship message")
	var dict = {}
	dict["message_type"] = "buy_ship"
	dict["ship_class_qualified_name"] = ship_class
	dict["ship_name"] = ship_name
	dict["primary_color"] = color1
	dict["secondary_color"] = color2
	queue_outgoing_message(dict)
	
func buy_fuel(quantity):
	print("sending buy fuel message")
	var dict = {}
	dict["message_type"] = "purchase_fuel"
	dict["quantity"] = quantity
	queue_outgoing_message(dict)
	
func load_passengers(destination, quantity):
	print("sending load passengers message")
	var dict = {}
	dict["message_type"] = "load_passengers"
	dict["destination_station"] = destination
	dict["quantity"] = quantity
	queue_outgoing_message(dict)
	
func send_json_message(json_message):
	_client.get_peer(1).put_packet(str(json_message).to_utf8())
	
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
