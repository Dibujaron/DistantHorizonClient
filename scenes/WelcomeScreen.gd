extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# game start flow should be this:
# if you select guest on mainscreen: "guest" -> game start (done)
# if you select login on mainscreen:
#    if no characters: create new character -> game start
#    if one character: 'resume' or 'create new character' -> game start
#    if multiple characters: 'resume' uses latest

func _ready():
	hide()
	var new_char_button = $MainBox/NewCharacterCenter/NewCharacterButton
	new_char_button.connect("pressed", self, "_new_character_pressed")
	$StartLoginRequest.connect("request_completed", self, "_on_start_login_request_complete")
	$ActorCreateOrDeleteRequest.connect("request_completed", self, "_on_refresh_actors_request_complete")
	var error = $StartLoginRequest.request("http://distant-horizon.io/client_login")
	if error != OK:
		var username_label = get_node("MainBox/UsernameLabel")
		username_label.text = "Error: failed to connect to session server."
	adjust_sizing()
		
func _on_start_login_request_complete(result, response_code, headers, body):
	print("completed start login request.")
	var json = JSON.parse(body.get_string_from_utf8()).result
	Global.init_session_info(json)
	if Global.is_user_guest() or Global.is_user_debug():
		print("skipping to join game.")
		_join_game() #skip ahead, don't need any more menus.
	else:
		print("User is logged in, activating menu.")
		var actors = json["server_data"]["actors"]
		activate_menu(actors)
		
func create_actor(actor_name):
	var username = Global.qualified_username
	var server_addr = Global.server_address()
	var request_url = "http://distant-horizon.io/create_actor"
	var headers = ["Content-Type: application/json"]
	print(request_url)
	var query = '{"display_name": "' + actor_name + '"}'
	var error = $ActorCreateOrDeleteRequest.request(request_url, headers, false, HTTPClient.METHOD_POST, query)
	if error != OK:
		var username_label = get_node("MainBox/UsernameLabel")
		username_label.text = "Error: failed to confirm login. Please restart game."
		adjust_sizing()
		show()
		
func _on_refresh_actors_request_complete(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8()).result
	print("actor refreshing request complete, json is ", json)
	if json["success"]:
		activate_menu(json["acct_data"]["actors"])
	else:
		print("error: refresh actors request failed. response is ", json)
	
func activate_menu(actors_json):
	print("activating menu.")
	for child in $MainBox/CharacterList.get_children():
		$MainBox/CharacterList.remove_child(child)
		
	var existing_actor_scene = preload("res://scenes/menu/ExistingActor.tscn")
	for actor_json in actors_json:
		var inst = existing_actor_scene.instance()
		$MainBox/CharacterList.add_child(inst)
		inst.json_init(self, actor_json)
	var username_label = get_node("MainBox/UsernameLabel")
	if Global.is_user_guest():
		username_label.text = "Warning: playing as guest, progress will not be saved!"
	else:
		username_label.text = "Welcome, " + Global.get_display_username() + "!"
	adjust_sizing()
	show()
	
func _process(delta):
	adjust_sizing()
	
func adjust_sizing():
	var screen_size = get_viewport_rect().size
	var my_size = rect_size
	var screen_center = screen_size * 0.5
	var half_my_size = my_size * 0.5
	rect_position = screen_center - half_my_size	
func _join_game():
	get_tree().change_scene("res://scenes/Space.tscn")
	
func _new_character_pressed():
	$CreateNewActorPopup.popup_centered()
