extends Node

var chosenPrimaryColor: Color = Color.blue
var chosenSecondaryColor: Color = Color.white

var token = JavaScript.eval("")
export var gravity_constant_fudge = 50.0
export var gravity_constant_base = 6.67408
export var gravity_constant_exp = -11.0
export var production_server_url = "ws://localhost:25611/ws/"
export var debug_server_url = "ws://localhost:25611/ws/"

var primary_player = null

export var ship_scenes = {
	"phe.thumper": preload("res://scenes/ship/Ship_PHE_Thumper.tscn"),
	"rijay.mockingbird": preload("res://scenes/ship/Ship_Rijay_Mockingbird.tscn"),
	"rijay.swallow": preload("res://scenes/ship/Ship_Rijay_Swallow.tscn"),
	"radi.kx6": preload("res://scenes/ship/Ship_RADI_kx6.tscn"),
	"phe.longhorn": preload("res://scenes/ship/Ship_PHE_Longhorn.tscn")
}

var gravity_constant = gravity_constant_base * pow(10, gravity_constant_exp) * gravity_constant_fudge

func should_vanish_docked_ai_ships():
	return false
	
func server_url():
	if OS.is_debug_build():
		return debug_server_url
	else:
		return production_server_url
		
func angular_diff(a, b):
	var vecA = polar2cartesian(1, a)
	var vecB = polar2cartesian(1, b)
	return vecB.angle_to(vecA)
	
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
	
func get_chat_hud():
	return get_space().get_node("GuiCanvas").get_node("BottomLeftHUD")
	
func get_compass_hud():
	return get_space().get_node("GuiCanvas").get_node("BottomRightHUD")

func get_socket_client():
	return get_space().get_node("WebSocketClient")

func set_primary_player(player):
	self.primary_player = player	
	
func get_primary_player():
	return primary_player
	
func get_current_zoom():
	return get_primary_player().get_node("Camera2D").zoom.x

