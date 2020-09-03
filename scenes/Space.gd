extends Node2D

var initialized_orbiters = false
var startup_initialized_ships = false
var planets = {}
var stations = {}
var ships = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func receive_world_update(message):
	if not initialized_orbiters:
		initialize_orbiters(message)
		initialized_orbiters = true
	else:
		json_update_orbiters(message)
		
func receive_station_menu_info(message):
	var canvas = $GuiCanvas
	var menu = canvas.get_node("StationMenu")
	if not menu:
		menu = preload("res://scenes/station/StationMenu.tscn").instance()
		canvas.add_child(menu)
	menu.init(message)

func receive_station_menu_close(message):
	var canvas = $GuiCanvas
	var menu = canvas.get_node("StationMenu")
	if menu:
		canvas.remove_child(menu)
		
func receive_initial_ships(message):
	if not startup_initialized_ships:
		initialize_ships_startup(message)
		startup_initialized_ships = true
	else:
		print("error received initial ships message twice.")
	
func receive_ships_added(message):
	initialize_added_ships(message)
	
func receive_ships_removed(message):
	cleanup_removed_ships(message)

func receive_ship_docked(message):
	var docked_message = message["ship_docked"]
	var ship_id = docked_message["id"]
	var ship = ships[ship_id]
	ship.json_receive_docked(docked_message)
	
func receive_ship_undocked(message):
	var undocked_message = message["ship_undocked"]
	var ship_id = undocked_message["id"]
	var ship = ships[ship_id]
	ship.json_receive_undocked(undocked_message)
	
func receive_ship_inputs_update(message):
	var inputs_update = message["ship_inputs"]
	var ship_id = inputs_update["id"]
	var ship = ships[ship_id]
	ship.json_update_inputs(inputs_update)
		
func receive_ship_heartbeats(message):
	var json_ships = message["ship_heartbeats"]
	for ship_info in json_ships:
		var ship_id = ship_info["id"]
		if ships.has(ship_id):
			var ship = ships[ship_id]
			ship.json_sync_state(ship_info)
		else:
			print("error got heartbeat for unitialized ship ", ship_id)
		
func json_update_orbiters(message):
	var world_state = message["world_state"]
	var json_planets = world_state["planets"]
	var json_stations = world_state["stations"]

	for planet_info in json_planets:
		var planet = planets[planet_info["name"]]
		planet.json_update(planet_info)
	
	for station_info in json_stations:
		var station = stations[station_info["name"]]
		station.json_update(station_info)
		
func initialize_ships_startup(message):
	initialize_added_ships(message)
	
	print("initializing player's ship.")
	var my_ship_id = message["ship_id"]
	var my_ship = ships[my_ship_id]
	var pilot = $PlayerPilot
	remove_child(pilot)
	my_ship.add_child(pilot)
	$GuiCanvas/HUD.visible = true
	$GuiCanvas/HUD.link_ship(my_ship)
	my_ship.is_player_ship = true
	
func initialize_added_ships(message):
	var json_ships = message["ships_added"]
	for ship_info in json_ships:
		init_ship(ship_info)
	print("initialized ", json_ships.size(), " new ships.")
		
func init_ship(ship_info):
	var ship_id = ship_info["id"]
	if ships.has(ship_id):
		print("error attempted to register ship ", ship_id, " but it is already registered.")
	else :
		var ship_scene = Global.ship_scenes[ship_info["type"]]
		var ship = ship_scene.instance()
		ships[ship_id] = ship
		add_child(ship)
		ship.json_init(ship_info)

func cleanup_removed_ships(removed_info):
	var removed_ids = removed_info["ships_removed"]
	for ship_id in removed_ids:
		if ships.has(ship_id):
			var ship = ships[ship_id]
			ship.get_parent().remove_child(ship)
			ships.erase(ship_id)
			print("removed ship ", ship_id, " there are ", ships.size(), " ships registered.")
		else:
			print("error attempted to remove unregistered ship ", ship_id)
		
func initialize_orbiters(message):
	var player_id = message["player_id"]
	var world_state = message["world_state"]
	var json_planets = world_state["planets"]
	var json_stations = world_state["stations"]

	var planet_scene = preload("res://scenes/orbiter/Planet.tscn")
	for planet_info in json_planets:
		var planet = planet_scene.instance()
		planet.name = planet_info["name"]
		planets[planet.name] = planet
		planet.add_to_group("planets")
		
	for planet_info in json_planets:
		var planet = planets[planet_info["name"]]
		var parent_name = planet_info["parent"]
		if parent_name:
			planet.has_parent = true
			var parent_node = planets[parent_name]
			parent_node.add_child(planet)
		else:
			add_child(planet)
		planet.json_init(planet_info)
		
	var station_scene = preload("res://scenes/station/Station.tscn")
	for station_info in json_stations:
		var station = station_scene.instance()
		station.name = station_info["name"]
		stations[station.name] = station
		station.add_to_group("stations")
		if station_info["parent"]:
			station.has_parent = true
			var parent_name = station_info["parent"]
			var parent_node = planets[parent_name]
			parent_node.add_child(station)
		else:
			add_child(station)
		station.json_init(station_info)
