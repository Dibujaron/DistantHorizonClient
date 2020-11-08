extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _ready():
	var join_button = get_node("VBoxContainer/JoinButton")
	join_button.connect("pressed", self, "_join_game")
	get_node("VBoxContainer/CommunityButtons/Discord").connect("pressed", self, "_open_discord")
	get_node("VBoxContainer/CommunityButtons/Reddit").connect("pressed", self, "_open_reddit")
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	$HTTPRequest.request("http://distant-horizon.io/me")
	join_button.disabled = true
	
func _process(delta):
	var screen_size = get_viewport_rect().size
	var my_size = rect_size
	var screen_center = screen_size * 0.5
	var half_my_size = my_size * 0.5
	rect_position = screen_center - half_my_size

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	Global.init_user_info(json.result)
	var join_button = get_node("VBoxContainer/JoinButton")
	join_button.disabled = false
	join_button.text = "Join game as " + Global.get_display_username()
	
func _join_game():
	get_tree().change_scene("res://scenes/Space.tscn")
	
func _open_reddit():
	OS.shell_open("https://old.reddit.com/r/distanthorizon/")
	
func _open_discord():
	OS.shell_open("https://discord.gg/8UNdWxA")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
