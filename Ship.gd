extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var rotation_speed = 0

var main_engines
var port_thrusters
var starboard_thrusters
var fore_thrusters
var aft_thrusters
var docking_ports

#modified by controls of child component
var main_engines_active = false
var port_thrusters_active = false
var starboard_thrusters_active = false
var fore_thrusters_active = false
var aft_thrusters_active = false
var tiller_left = false
var tiller_right = false

var docked_to_station = null
var docked_to_port = null
var docked_from_port = null
var currently_inside_planet = false

var navigating = false
var nav_target_vel = Vector2(0,0)
var nav_target_pos = Vector2(0,0)
var nav_bezier = null
var Bezier = load("Bezier.gd")
var main_engine_thrust = 0.0
var manu_engine_thrust = 0.0
var rotation_power = 0.0
var rotation_error_adjust = 0.0
var rotation_error = 0.0
var velocity = Vector2(0,0)
var initialized = false
var is_player_ship = false

var hold_size = 0
var hold_occupied = 0

export var default_primary_color = Color.blue
export var default_secondary_color = Color.white

func _ready():
	_set_primary_color(default_primary_color)
	_set_secondary_color(default_secondary_color)
	
func docked():
	return docked_to_station and docked_from_port and docked_to_port
	
func _set_primary_color(color):
	$Color1.modulate = color
	if has_node("Color1Shaded"):
		$Color1Shaded.modulate = Color.from_hsv(color.h, color.s, color.v - 0.1)
	
func _set_secondary_color(color):
	$Color2.modulate = color
	if has_node("Color2Shaded"):
		$Color2Shaded.modulate = Color.from_hsv(color.h, color.s, color.v - 0.1)
	
func json_init(json):
	main_engine_thrust = json["main_engine_thrust"]
	manu_engine_thrust = json["manu_engine_thrust"]
	rotation_power = json["rotation_power"]
	rotation_error_adjust = rotation_power / 10
	global_rotation = json["rotation"]
	global_position = Global.json_to_vec(json["global_pos"])
	hold_size = json["hold_size"]
	velocity = Global.json_to_vec(json["velocity"])
	var primary_color = Global.json_to_color(json["primary_color"])
	var secondary_color = Global.json_to_color(json["secondary_color"])
	_set_primary_color(primary_color)
	_set_secondary_color(secondary_color)
	# If this is the player's ship, update the rotation of the compass needle
	if is_player_ship:
			get_node("/root/Space/GuiCanvas/HUD/Compass/Needle").global_rotation = global_rotation
	
	#json_update_inputs(json)
	initialized = true

func json_receive_docked(json):
	var my_port_info = json["ship_port"]
	var station_name = json["station_identifying_name"]
	var station_port = json["station_port"]
	var stations = get_tree().get_nodes_in_group("Stations")
	for station in stations:
		if station.orbiter_name == station_name:
			docked_to_station = station
			break
			#var space_node = get_tree().get_root().get_node("Space")
			#space_node.remove_child(self)
			#station.add_child(self)
			#velocity = Vector2(0,0)
			#var station_port_relative = Global.json_to_vec(station_port["relative_position"])
			#var my_port_relative = Global.json_to_vec(my_port_info["relative_position"])
			#rotation = station_port["relative_rotation"] + my_port_info["relative_rotation"]
			#rotation_error = 0.0
			#position = station_port_relative + (my_port_relative * -1.0).rotated(rotation)
	docked_from_port = my_port_info
	docked_to_port = station_port
	for engine in main_engines:
		engine.set_enabled(false)
	for thruster in port_thrusters:
		thruster.set_enabled(false)
	for thruster in starboard_thrusters:
		thruster.set_enabled(false)
	for thruster in fore_thrusters:
		thruster.set_enabled(false)
	for thruster in aft_thrusters:
		thruster.set_enabled(false)
	
func json_receive_undocked(json):
	json_sync_state(json)
	var expected_rotation = json["rotation"]
	global_rotation = expected_rotation
	var expected_position = Global.json_to_vec(json["global_pos"])
	global_position = expected_position
	var expected_velocity = Global.json_to_vec(json["velocity"])
	velocity = expected_velocity
	docked_to_station = null
	docked_from_port = null
	docked_to_port = null
	
var left_press_time = 0
var left_press_start_tick = 0
var left_press_start_phys_tick = 0
func json_update_inputs(json):
	main_engines_active = json["main_engines"]
	port_thrusters_active = json["port_thrusters"]
	starboard_thrusters_active = json["stbd_thrusters"]
	fore_thrusters_active = json["fore_thrusters"]
	aft_thrusters_active = json["aft_thrusters"]
	tiller_left = json["rotating_left"]
	tiller_right = json["rotating_right"]
	for engine in main_engines:
		engine.set_enabled(main_engines_active)
	for thruster in port_thrusters:
		thruster.set_enabled(port_thrusters_active)
	for thruster in starboard_thrusters:
		thruster.set_enabled(starboard_thrusters_active)
	for thruster in fore_thrusters:
		thruster.set_enabled(fore_thrusters_active)
	for thruster in aft_thrusters:
		thruster.set_enabled(aft_thrusters_active)
	json_sync_state(json)
	
var last_sync_time = 0.0
func json_sync_state(json):
	var sync_delta = (OS.get_ticks_msec() - last_sync_time) / 1000.0
	navigating = json["navigating"]
	hold_occupied = json["hold_occupied"]
	if docked():
		var expected_position = Global.json_to_vec(json["global_pos"])
		global_position = expected_position
		var expected_rotation = json["rotation"]
		global_rotation = expected_rotation
		velocity = Vector2(0,0)
	else:
		var expected_rotation = json["rotation"]
		var expected_position = Global.json_to_vec(json["global_pos"])
		var expected_velocity = Global.json_to_vec(json["velocity"])
		# If this is the player's ship, update the rotation of the compass needle
		if is_player_ship:
			get_node("/root/Space/GuiCanvas/HUD/Compass/Needle").global_rotation = global_rotation
		if navigating:
			var targ_vel = Global.json_to_vec(json["targ_velocity"])
			var targ_pos = Global.json_to_vec(json["targ_position"])
			if nav_target_vel != targ_vel or nav_target_pos != targ_pos:
				nav_target_pos = targ_pos
				nav_target_vel = targ_vel
				nav_bezier = Bezier.new()
				nav_bezier.setup(global_position, velocity, nav_target_pos, nav_target_vel, main_engine_thrust)
			var nav_target_vel = Vector2(0,0)
			var nav_target_pos = Vector2(0,0)
			var nav_bezier = null
		else:
			global_rotation = expected_rotation
			var expected_pos_after_time = expected_position + (expected_velocity * sync_delta)
			var true_pos_after_time = global_position + (velocity * sync_delta)
			var velocity_adj = expected_pos_after_time - true_pos_after_time
			velocity += velocity_adj
	last_sync_time = OS.get_ticks_msec()

var tick_count = 0
var physics_tick_count = 0
func _process(delta):
	var inside_planet = get_inside_planet()	#if we just stopped being inside a planet, trigger z switch
	if currently_inside_planet and not inside_planet:
		z_index = z_index * -1
	currently_inside_planet = inside_planet
	
	if docked():
		var my_port_relative = Global.json_to_vec(docked_from_port.relative_position)
		var station_port_relative = Global.json_to_vec(docked_to_port.relative_position)
		var rotation_offset = docked_to_port.relative_rotation + docked_from_port.relative_rotation
		global_rotation = docked_to_station.global_rotation + rotation_offset
		var docked_to_global_pos = docked_to_station.global_position + station_port_relative.rotated(docked_to_station.global_rotation)
		global_position = docked_to_global_pos + (my_port_relative * -1.0).rotated(global_rotation)
	else:
		if navigating:
			if nav_bezier.has_next_step(delta):
				var result = nav_bezier.step(delta, global_position)
				global_position = result[0]
				global_rotation = result[1]
				velocity = result[2]
				var thrust = result[3]
				var enable = thrust.length_squared() > (0.1 * 0.1)
				for engine in main_engines:
					engine.set_enabled(enable)
			pass
		else:
			if main_engines_active:
				velocity += Vector2(0,-main_engine_thrust).rotated(global_rotation) * delta
			if starboard_thrusters_active:
				velocity += Vector2(-manu_engine_thrust, 0).rotated(global_rotation) * delta
			if port_thrusters_active:
				velocity += Vector2(manu_engine_thrust, 0).rotated(global_rotation) * delta
			if fore_thrusters_active:
				velocity += Vector2(0, manu_engine_thrust).rotated(global_rotation) * delta
			if aft_thrusters_active:
				velocity += Vector2(0, -manu_engine_thrust).rotated(global_rotation) * delta
			if tiller_left:
				global_rotation -= rotation_power * delta #todo multiply by delta
				# If this is the player's ship, update the rotation of the compass needle
				if is_player_ship:
					get_node("/root/Space/GuiCanvas/HUD/Compass/Needle").global_rotation = global_rotation
			if tiller_right:
				global_rotation += rotation_power * delta
				# If this is the player's ship, update the rotation of the compass needle
				if is_player_ship:
					get_tree().get_root().get_node("/root/Space/GuiCanvas/HUD/Compass/Needle").global_rotation = global_rotation
			global_position += velocity * delta
	tick_count += 1
		
func _physics_process(delta):
	if not navigating: # manually controlled
		velocity += Global.get_gravity_acceleration(global_position) * delta
	physics_tick_count += 1
	
func get_inside_planet():
	var bodies = get_tree().get_nodes_in_group("Planets")
	
	var inside_any_planet = false
	for body in bodies:
		var body_position = body.global_position
		var min_alt_squared = pow(body.min_orbital_altitude,2)
		var r_squared = abs((body_position - global_position).length_squared())
		if(r_squared < min_alt_squared):
			return true
	return false
