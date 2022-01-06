extends Node2D

var initialized_orbiters = false
var initialized_ships = false
var has_initialized_own_ship = false

var planets = {}
var stations = {}
var ships = {}

func absolute_position():
	return position
	
func initialization_complete():
	return initialized_orbiters and initialized_ships and has_initialized_own_ship
	
var objects_visible = false
func _process(_delta):
	if not objects_visible and initialization_complete():
		for planet in planets.values():
			planet.show()
		for station in stations.values():
			station.show()
		for ship in ships.values():
			if ship.should_be_visible():
				ship.show()
		objects_visible = true
		
func receive_world_update(message):
	if not initialized_orbiters:
		initialize_orbiters(message)
		initialized_orbiters = true
	else:
		json_update_orbiters(message)
		
func receive_station_menu_info(message):
	var canvas = $GuiCanvas
	var menu = canvas.get_node_or_null("StationMenu")
	if not menu:
		menu = preload("res://scenes/station/StationMenu.tscn").instance()
		canvas.add_child(menu)
	menu.init(message)

func receive_station_menu_close(_message):
	var canvas = $GuiCanvas
	var menu = canvas.get_node_or_null("StationMenu")
	if menu:
		canvas.remove_child(menu)

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

func receive_money_earned(message):
	var amount = message["money_earned"]
	var player = Global.get_primary_player()
	print("got money earned message of amount " + str(amount))
	player.display_money_earned(amount)
	
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
		
var previous_ship_id = ""
func initialize_added_ships(message):
	var json_ships = message["ships_added"]
	var my_ship_id = message["ship_id"]
	for ship_info in json_ships:
		var ship_id = ship_info["id"]
		if ships.has(ship_id):
			print("error attempted to register ship ", ship_id, " but it is already registered.")
		else:
			var ship_scene = Global.ship_scenes[ship_info["type"]]
			var ship = ship_scene.instance()
			if not initialization_complete():
				ship.hide()
			ships[ship_id] = ship
			add_child(ship)
			ship.json_init(ship_info)
			if my_ship_id == ship_id and (not has_initialized_own_ship or previous_ship_id != my_ship_id):
				print("initializing player's ship.")
				var pilot = Global.get_primary_player()
				pilot.get_parent().remove_child(pilot)
				ship.add_child(pilot)
				$GuiCanvas/BottomRightHUD.visible = true
				$GuiCanvas/BottomRightHUD.link_ship(ship)
				$GuiCanvas/BottomLeftHUD.visible = true
				$GuiCanvas/BottomLeftHUD.link_ship(ship) #todo clean this up
				ship.init_as_player_ship()
				has_initialized_own_ship = true
	previous_ship_id = my_ship_id
	initialized_ships = true
	print("initialized ", json_ships.size(), " new ships.")

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
	var world_state = message["world_state"]
	var json_planets = world_state["planets"]
	var json_stations = world_state["stations"]

	var planet_scene = preload("res://scenes/orbiter/Planet.tscn")
	for planet_info in json_planets:
		var planet = planet_scene.instance()
		if not initialization_complete():
			planet.hide()
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
		if not initialization_complete():
			station.hide()
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
		if station.name == "Stn_Arion_Spaceport":
			var circle = preload("res://scenes/player/TargetingCircle.tscn").instance()
			circle.navigate_to(station.name)
	Global.get_navigation_menu().init()
