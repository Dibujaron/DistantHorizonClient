extends MarginContainer

var session_server_exists = false

func _ready():
	hide()
	var new_char_button = $MainBox/NewCharacterCenter/NewCharacterButton
	new_char_button.connect("pressed", self, "_new_character_pressed")
	var _connect_result = $StartLoginRequest.connect("request_completed", self, "_on_start_login_request_complete")
	var _connect_result_2 = $ActorCreateOrDeleteRequest.connect("request_completed", self, "_on_refresh_actors_request_complete")
	if session_server_exists:
		var error = $StartLoginRequest.request("http://distant-horizon.io/client_login")
		if error != OK:
			print("Failed to connect to session server, falling back to debug mode.")
	else:
		Global.init_session_info(null)
		_join_game()
	adjust_sizing()
		
func _on_start_login_request_complete(_result, _response_code, _headers, body):
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
	var request_url = "http://distant-horizon.io/create_actor"
	var headers = ["Content-Type: application/json"]
	print(request_url)
	var query = '{"display_name": "' + actor_name + '"}'
	var error = $ActorCreateOrDeleteRequest.request(request_url, headers, false, HTTPClient.METHOD_POST, query)
	if error != OK:
		var username_label = get_node("MainBox/UsernameLabel")
		username_label.text = "Error: failed to confirm login. Please restart game."
		show()
		adjust_sizing()
		
func delete_actor(unique_id):
	var request_url = "http://distant-horizon.io/delete_actor"
	var headers = ["Content-Type: application/json"]
	print("unique ID is ", unique_id)
	var query = '{"actor_id": "' + str(unique_id) + '"}'
	print("submitting delete actor request with query ", query)
	var error = $ActorCreateOrDeleteRequest.request(request_url, headers, false, HTTPClient.METHOD_POST, query)
	if error != OK:
		var username_label = get_node("MainBox/UsernameLabel")
		username_label.text = "Error: failed to delete actor. Please restart game."
		show()
		adjust_sizing()
		
func _on_refresh_actors_request_complete(_result, _response_code, _headers, body):
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
	show()
	adjust_sizing()
	
func adjust_sizing():
	var screen_size = get_viewport_rect().size
	var my_size = rect_size
	var screen_center = screen_size * 0.5
	var half_my_size = my_size * 0.5
	var new_x = screen_center.x - half_my_size.x
	var new_y = screen_size.y * 0.10
	rect_position = Vector2(new_x, new_y)
	
func _join_game():
	var _scene_result = get_tree().change_scene("res://scenes/Space.tscn")
	
func _new_character_pressed():
	$CreateNewActorPopup.popup_centered()
