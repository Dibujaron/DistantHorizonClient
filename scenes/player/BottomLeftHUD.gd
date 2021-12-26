extends Control

var linked_ship = null
var lines_total = 0

export var line_height = 20
export var lines_show_normally = 5
export var lines_show_focused = 30

export (NodePath) var chat_display_path
export (NodePath) var chat_input_path

onready var chat_display = get_node(chat_display_path)
onready var chat_input = get_node(chat_input_path)

func _ready():
	chat_input.hide()
	
func _process(_delta):
	pass
		
func link_ship(ship):
	if linked_ship:
		print("error attempted to link ship to HUD but already linked.")
		print("existing ship: ", linked_ship)
		print("new ship: ", ship)
	else:
		print("linked ship to hud.")
		linked_ship = ship
		
func get_linked_ship():
	return linked_ship

func receive_chat_message(message_json):
	var message_txt = message_json["payload"]
	add_chat_message(message_txt)
	
func add_chat_message(message_txt):
	chat_display.push_chat_message(message_txt)
	
func send_chat_message():
	var message_txt = chat_input.text
	unfocus_chat()
	if(message_txt.length() > 0):
		if message_txt == "/debugrotation":
			add_chat_message("ship true rotation is: " + str(rad2deg(get_linked_ship().global_rotation)) + "deg")
			add_chat_message("ship rotation error is: " + str(rad2deg(get_linked_ship().rotation_error)) + "deg")
		elif message_txt == "/coords" or message_txt == "/coordinates":
			var position = get_linked_ship().global_position
			var x = int(position.x)
			var y = int(position.y)
			add_chat_message("ship coordinates: " + str(x) + ", " + str(y))
		else:
			Global.get_socket_client().send_chat_message(message_txt)
	
func is_chat_focused():
	return chat_input.has_focus()
	
func cancel_message():
	unfocus_chat()
	print("cancelled chat.")
	
func unfocus_chat():
	chat_input.text = ""
	chat_input.release_focus()
	chat_input.hide()
	chat_display.on_chat_unfocused()
		
func focus_chat(starting_text):
	chat_input.text = starting_text
	chat_input.set_cursor_position(starting_text.length())
	chat_input.show()
	chat_input.grab_focus()
	chat_display.on_chat_focused()
	print("focused chat.")
