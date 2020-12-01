extends Node

var chosenPrimaryColor: Color = Color.blue
var chosenSecondaryColor: Color = Color.white

export var gravity_constant_fudge = 50.0
export var gravity_constant_base = 6.67408
export var gravity_constant_exp = -11.0
var debug_logins = true

var production_server_address = null
export var debug_server_address = "localhost:25611"

export var request_batching = true
var primary_player = null
var targeting_circle = null
var display_username = null
var qualified_username = null
var actor_name = null
var login_key = null
var authenticated = false

export var ship_scenes = {
	"phe.thumper": preload("res://scenes/ship/Ship_PHE_Thumper.tscn"),
	"rijay.mockingbird": preload("res://scenes/ship/Ship_Rijay_Mockingbird.tscn"),
	"rijay.swallow": preload("res://scenes/ship/Ship_Rijay_Swallow.tscn"),
	"radi.kx6": preload("res://scenes/ship/Ship_RADI_kx6.tscn"),
	"phe.longhorn": preload("res://scenes/ship/Ship_PHE_Longhorn.tscn"),
	"rijay.pegasus": preload("res://scenes/ship/Ship_Rijay_Pegasus.tscn")
}

var gravity_constant = gravity_constant_base * pow(10, gravity_constant_exp) * gravity_constant_fudge

func should_vanish_docked_ai_ships():
	return false
	
func init_session_info(msg):
	print("got message ", msg)
	production_server_address = msg["server_address"]
	var logged_in = msg["logged_in"]
	authenticated = logged_in
	if logged_in:
		var user_info = msg["discord_user"]
		display_username = user_info["username"]
		qualified_username = user_info["username"] + user_info["discriminator"]
		login_key = msg["server_data"]["token"]
		print("session initialized with username ", qualified_username)
	elif OS.is_debug_build() and debug_logins:
		display_username = "DebugUser"
		qualified_username = "Debug0000"
		login_key = "debug"
		authenticated = true
		actor_name = "debug"
		print("fake debug user session initialized.")
	else:
		display_username = "Guest"
		qualified_username = null
		print("session started as guest.")

func get_display_username():
	return display_username
	
func is_user_guest():
	return get_qualified_username() == null
	
func is_user_debug():
	return get_qualified_username() == "Debug0000"
	
func get_qualified_username():
	return qualified_username
	
func server_address():
	if OS.is_debug_build():
		return debug_server_address
	else:
		return production_server_address

func find_station(station_name):
	var stations = get_tree().get_nodes_in_group("Stations")
	for station in stations:
		if station.orbiter_name == station_name:
			return station
	return null
	
func json_to_vec(json):
	return Vector2(json["x"],json["y"])

func json_to_color(json):
	return Color8(json["r"], json["g"], json["b"])
	
func get_gravity_acceleration(pos):
	var total_acceleration = Vector2()
	var bodies = get_tree().get_nodes_in_group("Planets")
	
	for body in bodies:
		var body_mass = body.mass
		var body_position = body.global_position
		var min_alt_squared = pow(body.min_orbital_altitude,2)
		var r_squared = abs((body_position - pos).length_squared())
		if(r_squared < min_alt_squared):
			r_squared = min_alt_squared
		var f_magnitude = gravity_constant * body_mass / r_squared
		var acceleration = (body_position - pos).normalized() * f_magnitude
		total_acceleration = total_acceleration + acceleration
	return total_acceleration
	
func get_space():
	return get_tree().get_root().get_node("Space")
	
func get_gui_canvas():
	return get_space().get_node("GuiCanvas")
	
func get_chat_hud():
	return get_gui_canvas().get_node("BottomLeftHUD")
	
func get_compass_hud():
	return get_gui_canvas().get_node("BottomRightHUD")

func get_navigation_menu():
	return get_gui_canvas().get_node("NavigationMenu")
	
func get_station_menu():
	return get_gui_canvas().get_node_or_null("StationMenu")

func is_station_menu_open():
	return get_station_menu() != null
	
func get_socket_client():
	return get_space().get_node("WebSocketClient")

func set_primary_player(player):
	self.primary_player = player	
	
func get_primary_player():
	return primary_player
	
func get_primary_player_ship():
	var parent = get_primary_player().get_parent()
	if parent == get_space():
		return null
	else:
		return parent
	
func set_targeting_circle(circle):
	self.targeting_circle = circle

func get_targeting_circle():
	return targeting_circle
	
func get_current_zoom():
	return get_primary_player().get_node("Camera2D").zoom.x
	
func angular_diff(from, to):
	return fposmod(to - from + PI, PI * 2) - PI
	
func pretty_print_distance(dist):
	if dist >= 500000:
		return str(stepify(dist / 1000000,0.01)) + " Muu"
	elif dist > 1000:
		return str(round(dist / 1000)) + " Kuu"
	else:
		return str(round(dist)) + " uu"

