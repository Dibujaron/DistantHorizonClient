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
	
func _process(delta):
	pass
		
func link_ship(ship):
	linked_ship = ship
		
func get_linked_ship():
	return linked_ship

func receive_chat_message(message_json):
	var message_txt = message_json["payload"]
	chat_display.push_chat_message(message_txt)
	
func send_chat_message():
	var message_txt = chat_input.text
	unfocus_chat()
	if(message_txt.length() > 0):
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
		
func focus_chat():
	chat_input.show()
	chat_input.grab_focus()
	chat_display.on_chat_focused()
	print("focused chat.")
