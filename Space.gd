extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var ship_scenes = {
	"phe.thumper": preload("res://Ship_PHE_Thumper.tscn"),
	"rijay.mockingbird": preload("res://Ship_Rijay_Mockingbird.tscn")
}

var initialized = false
var planets = {}
var stations = {}
var ships = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func receive_world_update(message):
	if not initialized:
		initialize(message)
		initialized = true
	else:
		json_update(message)

func json_update(message):
	var world_state = message["world_state"]
	var json_planets = world_state["planets"]
	var json_stations = world_state["stations"]
	var json_ships = world_state["ships"]	
	
	for planet_info in json_planets:
		var planet = planets[planet_info["name"]]
		planet.json_update(planet_info)
	
	for station_info in json_stations:
		var station = stations[station_info["name"]]
		station.json_update(station_info)
		
	#todo handle removing ships better than this
	var updated_ships = []
	for ship_info in json_ships:
		var ship_id = ship_info["id"]
		if ships.has(ship_id):
			var ship = ships[ship_id]
			ship.json_update(ship_info)
		else:
			init_ship(ship_info)
		updated_ships.append(ship_id)
		
	var removed_ships = []
	for ship_id in ships:
		if not updated_ships.has(ship_id):
			removed_ships.append(ship_id)
	
	for ship_id in removed_ships:
		var ship = ships[ship_id]
		ship.get_parent().remove_child(ship)
		ships.erase(ship_id)
	
func init_ship(ship_info):
	var ship_scene = ship_scenes[ship_info["type"]]
	var ship = ship_scene.instance()
	var ship_id = ship_info["id"]
	ships[ship_id] = ship
	add_child(ship)
	ship.json_init(ship_info)
	
func initialize(message):
	var player_id = message["player_id"]
	var my_ship_id = message["ship_id"]
	var world_state = message["world_state"]
	var json_planets = world_state["planets"]
	var json_stations = world_state["stations"]
	var json_ships = world_state["ships"]
	
	for ship_info in json_ships:
		init_ship(ship_info)
		
	var my_ship = ships[my_ship_id]
	var pilot = $PlayerPilot
	remove_child(pilot)
	my_ship.add_child(pilot)
	
	var planet_scene = preload("res://Planet.tscn")
	for planet_info in json_planets:
		var planet = planet_scene.instance()
		planet.name = planet_info["name"]
		planets[planet.name] = planet
		planet.add_to_group("planets")
		
	for planet_info in json_planets:
		var planet = planets[planet_info["name"]]
		var parent_name = planet_info["parent"]
		if parent_name:
			var parent_node = planets[parent_name]
			parent_node.add_child(planet)
		else:
			add_child(planet)
		planet.json_init(planet_info)
		
	var station_scene = preload("res://TradeStation.tscn")
	for station_info in json_stations:
		var station = station_scene.instance()
		station.name = station_info["name"]
		stations[station.name] = station
		station.add_to_group("stations")
		if station_info.has("parent"):
			var parent_name = station_info["parent"]
			var parent_node = planets[parent_name]
			parent_node.add_child(station)
		else:
			add_child(station)
		station.json_init(station_info)

func json_to_vec(json):
	return Vector2(json["x"],json["y"])
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
