extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#export var socket_url = "ws://66.70.193.213:25611/ws/"
export var socket_url = "ws://localhost:25611/ws/"
export (NodePath) var space_path
onready var space = get_node(space_path)
# Called when the node enters the scene tree for the first time.
var _client = WebSocketClient.new()
var connected = false
func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
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
		get_parent().receive_world_update(json)
	else:
		print(parse_result.error_string)

func send_message(message):
	var err = _client.get_peer(1).put_packet(str(message).to_utf8())
	
func _process(delta):
	_client.poll()
	
func read_message():
	return _client.get_peer(1).get_packet().get_string_from_utf8()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
