extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var lines_display_focused = 60
export var lines_display_unfocused = 5
export var message_live_time_secs = 9
var message_live_time_msecs = 1000 * message_live_time_secs

var chat_focused = false
var update_required = false
var lines = []
var expiries = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var current_time = OS.get_system_time_msecs()
	while (expiries.size() > 0) && (current_time > expiries[0]):
		expiries.remove(0)
		lines.remove(0)
		update_required = true
	 
	if update_required:
		render_text()
		update_required = false
		
func render_text():
	var lines_to_display = get_lines_to_display()
	print("rendering ", lines_to_display, " lines of chat")
	var most_recent_index = lines.size()
	var least_recent_index = most_recent_index - lines_to_display
	print("least recent: ", least_recent_index, " most recent: ", most_recent_index)
	var text_to_display = ""
	for n in range(least_recent_index, most_recent_index, 1):
		text_to_display = text_to_display + "\n" + lines[n]
	text = text_to_display
	
func push_chat_message(message):
	print("[chat] ", message)
	var current_time = OS.get_system_time_msecs()
	var expiry = current_time + message_live_time_msecs
	print("pushed message with expiry ", expiry)
	lines.append(message)
	expiries.append(expiry)
	update_required = true

func get_lines_to_display():
	var max_lines = lines_display_unfocused
	if chat_focused:
		max_lines = lines_display_focused
	print("lines size: ", lines.size(), " focused: ", chat_focused)
	return min(lines.size(), max_lines)
	
func on_chat_focused():
	chat_focused = true
	update_required = true
	
func on_chat_unfocused():
	chat_focused = false
	update_required = true
	