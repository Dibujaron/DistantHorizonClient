extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	hide()
	var join_button = get_node("VBoxContainer/JoinButton")
	join_button.connect("pressed", self, "_join_game")
	get_node("VBoxContainer/CommunityButtons/Discord").connect("pressed", self, "_open_discord")
	get_node("VBoxContainer/CommunityButtons/Reddit").connect("pressed", self, "_open_reddit")
	$StartLoginRequest.connect("request_completed", self, "_on_start_login_request_complete")
	$ConfirmLoginRequest.connect("request_completed", self, "_on_confirm_login_request_complete")
	join_button.disabled = true
	var error = $StartLoginRequest.request("http://distant-horizon.io/client_start_login")
	if error != OK:
		var username_label = get_node("VBoxContainer/UsernameLabel")
		username_label.text = "Error: failed to connect to session server."
		
func _on_start_login_request_complete(result, response_code, headers, body):
	print("completed start login request.")
	var json = JSON.parse(body.get_string_from_utf8())
	Global.init_session_info(json.result)
	if Global.is_user_guest():
		activate_menu()
	else:
		var server_addr = Global.server_address()
		var request_url = "http://" + server_addr + "/confirm_client_login/" + Global.login_key
		var error = $ConfirmLoginRequest.request(request_url)
		if error != OK:
			var username_label = get_node("VBoxContainer/UsernameLabel")
			username_label.text = "Error: failed to connect to session server."
			show()
	
func _on_confirm_login_request_complete(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8()).result
	print("completed confirm login request, response is ", json)
	if json["confirmed"]:
		activate_menu()
	else:
		var username_label = get_node("VBoxContainer/UsernameLabel")
		username_label.text = "Error: failed to confirm login. Please restart game."
		show()
	
func activate_menu():
	print("activating menu.")
	var join_button = get_node("VBoxContainer/JoinButton")
	join_button.disabled = false
	var username_label = get_node("VBoxContainer/UsernameLabel")
	if Global.is_user_guest():
		username_label.text = "Warning: playing as guest, progress will not be saved!"
	else:
		username_label.text = "Welcome, " + Global.get_display_username() + "!"
	show()
	
func _process(delta):
	var screen_size = get_viewport_rect().size
	var my_size = rect_size
	var screen_center = screen_size * 0.5
	var half_my_size = my_size * 0.5
	rect_position = screen_center - half_my_size
	
func _join_game():
	get_tree().change_scene("res://scenes/Space.tscn")
	
func _open_reddit():
	OS.shell_open("https://old.reddit.com/r/distanthorizon/")
	
func _open_discord():
	OS.shell_open("https://discord.gg/8UNdWxA")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
