extends Node

var chosenPrimaryColor: Color = Color.blue
var chosenSecondaryColor: Color = Color.white

export var gravity_constant_fudge = 50.0
export var gravity_constant_base = 6.67408
export var gravity_constant_exp = -11.0
export var min_gravity_force_cutoff = 0.2
 
var debug_logins = true

var production_server_address = null
export var debug_server_address = "localhost:25611"

export var request_batching = true
var primary_player = null
var targeting_circle = null
var poi_circle = null
var true_position_indicator = null
var display_username = null
var qualified_username = null
var actor_id = null
var login_key = null
var authenticated = false

export var ship_scenes = {
	"phe.thumper": preload("res://scenes/ship/Ship_PHE_Thumper.tscn"),
	"rijay.mockingbird": preload("res://scenes/ship/Ship_Rijay_Mockingbird.tscn"),
	"rijay.swallow": preload("res://scenes/ship/Ship_Rijay_Swallow.tscn"),
	"aldrin.kx6": preload("res://scenes/ship/Ship_RADI_kx6.tscn"),
	"phe.longhorn": preload("res://scenes/ship/Ship_PHE_Longhorn.tscn"),
	"aldrin.pegasus": preload("res://scenes/ship/Ship_Rijay_Pegasus.tscn"),
	"rijay.crusader": preload("res://scenes/ship/Ship_Rijay_Crusader.tscn")
}

export var themes  = {
	"standard.big": preload("res://themes/Pixelar_Big.tres"),
	"standard": preload("res://themes/Pixelar_Tabs.tres"),
	"h1.big": preload("res://themes/Pixelar_H1_Big.tres"),
	"h1": preload("res://themes/Pixelar_H1.tres"),
	"h2.big": preload("res://themes/Pixelar_H2_Big.tres"),
	"h2": preload("res://themes/Pixelar_H2.tres"),
	"tabs.big": preload("res://themes/Pixelar_Tabs_Big.tres"),
	"tabs": preload("res://themes/Pixelar_Tabs.tres")
}

var gravity_constant = gravity_constant_base * pow(10, gravity_constant_exp) * gravity_constant_fudge

func should_vanish_docked_ai_ships():
	return false
	
func init_session_info(msg):
	print("got message ", msg)
	if msg != null:
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
			init_debug_session()
		else:
			display_username = "Guest"
			qualified_username = null
			actor_id = null
			print("session started as guest.")
	elif OS.is_debug_build() and debug_logins:
		init_debug_session()
		
func init_debug_session():
	display_username = "DebugUser"
	qualified_username = "Debug0000"
	login_key = "debug"
	authenticated = true
	actor_id = 0
	print("fake debug user session initialized.")	

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
	
func color_to_json(color):
	var dict = {}
	dict["r"] = color.r8
	dict["g"] = color.g8
	dict["b"] = color.b8
	return dict
	
var planet_cache = null
func get_gravity_acceleration(global_pos):
	var accel = Vector2()
	if planet_cache == null:
		planet_cache = get_tree().get_nodes_in_group("Planets")
	for it in planet_cache:
		var planet_pos = it.global_position
		var offset = (planet_pos - global_pos)
		var r_squared = offset.length_squared()
		var min_radius_squared = it.min_orbital_altitude_squared
		if r_squared < min_radius_squared:
			r_squared = min_radius_squared
		var force_mag = gravity_constant * it.mass / r_squared
		if force_mag > min_gravity_force_cutoff:
			accel += (offset.normalized() * force_mag)
	return accel
	
func get_gravity_acceleration_at_tick(global_pos, tick_offset):
	var accel = Vector2()
	if planet_cache == null:
		planet_cache = get_tree().get_nodes_in_group("Planets")
	for it in planet_cache:
		var planet_pos = it.global_pos_at_time(tick_offset)
		var offset = (planet_pos - global_pos)
		var r_squared = offset.length_squared()
		var min_radius_squared = it.min_orbital_altitude_squared
		if r_squared < min_radius_squared:
			r_squared = min_radius_squared
		var force_mag = gravity_constant * it.mass / r_squared
		if force_mag > min_gravity_force_cutoff:
			accel += (offset.normalized() * force_mag)
	return accel
	
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
	
func set_poi_circle(circle):
	self.poi_circle = circle
	
func get_poi_circle():
	if poi_circle == null:
		poi_circle = preload("res://scenes/player/PoiCircle.tscn").instance()
	return poi_circle
	
func get_true_position_indicator():
	if true_position_indicator == null:
		true_position_indicator = preload("res://scenes/TruePositionIndicator.tscn").instance()
		get_space().add_child(true_position_indicator)
	return true_position_indicator
	
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
	
func pretty_print_speed(speed):
	if speed >= 500000:
		return str(stepify(speed / 1000000,0.01)) + " Muu/s"
	elif speed > 1000:
		return str(stepify(speed / 1000,0.01)) + " Kuu/s"
	else:
		return str(round(speed)) + " uu/s"

func load_text_file(path):
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var text = f.get_as_text()
	f.close()
	return text
	
func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func get_station_by_name(name):
	var stations = get_tree().get_nodes_in_group("Stations")
	for station in stations:
		if station.orbiter_name == name:
			return station
	return null
