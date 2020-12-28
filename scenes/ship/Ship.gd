extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var rotation_speed = 0

var static_display = false

export var smoothing_boundary_position = 1024.0
var smoothing_boundary_position_squared = smoothing_boundary_position * smoothing_boundary_position
export var smoothing_boundary_rotation = deg2rad(10.0)
export var smoothing_correction_range = 8 #assuming no further inputs, a position error will self correct after x syncs
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

var main_engine_thrust = 0.0
var manu_engine_thrust = 0.0
var rotation_power = 0.0
var rotation_error_adjust = 0.0
var rotation_error = 0.0
var velocity = Vector2(0,0)
var current_rotation = 0.0
var initialized = false
var is_player_ship = false

var hold_size = 0
var hold_occupied = 0

export var primary_color = Color.blue
export var secondary_color = Color.white
export var max_rotation_correction = 0.0001

func _ready():
	pass
	_set_primary_color(primary_color)
	_set_secondary_color(secondary_color)
	#var center_mass_offset = _get_center_mass()
	#for child in get_children():
	#	child.position = child.position + center_mass_offset
	
func init_as_player_ship():
	is_player_ship = true
	add_breadcrumbs()
	
func toggle_breadcrumbs():
	if not docked():
		var breadcrumbs = get_node("Breadcrumbs")
		if breadcrumbs:
			remove_child(breadcrumbs)
		else:
			add_breadcrumbs()
	
func add_breadcrumbs():
	var breadcrumb_scene = preload("res://scenes/player/Breadcrumbs.tscn")
	var breadcrumbs = breadcrumb_scene.instance()
	add_child(breadcrumbs)
	
func _get_center_mass():
	return Vector2(0,0)
	
func docked():
	return docked_to_station and docked_from_port and docked_to_port
	
func _set_primary_color(color):
	print("setting primary color")
	$Color1.modulate = color
	if has_node("Color1Shaded"):
		$Color1Shaded.modulate = Color.from_hsv(color.h, color.s, color.v - 0.1)
	
func _set_secondary_color(color):
	$Color2.modulate = color
	if has_node("Color2Shaded"):
		$Color2Shaded.modulate = Color.from_hsv(color.h, color.s, color.v - 0.1)

func should_be_visible():
	if is_player_ship or static_display:
		return true
	else:
		return not (docked() and Global.should_vanish_docked_ai_ships())
		
func json_init(json):
	main_engine_thrust = json["main_engine_thrust"]
	manu_engine_thrust = json["manu_engine_thrust"]
	rotation_power = json["rotation_power"]
	global_rotation = json["rotation"]
	rotation_error = 0.0
	global_position = Global.json_to_vec(json["global_pos"])
	hold_size = json["hold_size"]
	velocity = Global.json_to_vec(json["velocity"])
	var primary_color = Global.json_to_color(json["primary_color"])
	var secondary_color = Global.json_to_color(json["secondary_color"])
	_set_primary_color(primary_color)
	_set_secondary_color(secondary_color)
	var docked = json["docked"]
	print("initializing with docked value: ", docked)
	if docked:
		var docked_info = json["docked_info"]
		json_receive_docked(docked_info)
	initialized = true

func json_receive_docked(json):
	var my_port_info = json["ship_port"]
	var station_name = json["station_identifying_name"]
	var station_port = json["station_port"]
	docked_to_station = Global.find_station(station_name)
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
	
	if is_player_ship:
		var targeting_circle = Global.get_targeting_circle()
		if targeting_circle.is_enabled():
			if targeting_circle.get_nav_target() == station_name:
				targeting_circle.stop_navigating()
	elif Global.should_vanish_docked_ai_ships():
		visible = false
	
func json_receive_undocked(json):
	json_sync_state(json)
	var expected_rotation = json["rotation"]
	global_rotation = expected_rotation
	rotation_error = 0.0
	var expected_position = Global.json_to_vec(json["global_pos"])
	global_position = expected_position
	var expected_velocity = Global.json_to_vec(json["velocity"])
	velocity = expected_velocity
	docked_to_station = null
	docked_from_port = null
	docked_to_port = null
	visible = true
	
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
	if not static_display:
		var sync_delta = (OS.get_ticks_msec() - last_sync_time) / 1000.0
		hold_occupied = json["hold_occupied"]
		if docked():
			var expected_position = Global.json_to_vec(json["global_pos"])
			global_position = expected_position
			var expected_rotation = json["rotation"]
			global_rotation = expected_rotation
			rotation_error = 0.0
			velocity = Vector2(0,0)
		else:
			var expected_rotation = json["rotation"]
			#current_rotation = expected_rotation
			var true_rotation = current_rotation
			var new_rotation_error = Global.angular_diff(expected_rotation, true_rotation)
			if abs(new_rotation_error) > smoothing_boundary_rotation:
				print("rotation error ", rad2deg(new_rotation_error), "deg for ship is past smoothing boundary, hard correcting.")
				rotation_error = 0.0
				current_rotation = expected_rotation
			elif is_zero_approx(new_rotation_error):
				rotation_error = 0.0
			else:
				rotation_error = new_rotation_error
	
			var expected_position = Global.json_to_vec(json["global_pos"])
			var expected_velocity = Global.json_to_vec(json["velocity"])
			var diff_squared = (global_position - expected_position).length_squared()
			if diff_squared > smoothing_boundary_position_squared:
				global_position = expected_position
				velocity = expected_velocity
			else:
				var expected_pos_after_time = expected_position + (expected_velocity * sync_delta * smoothing_correction_range)
				var true_pos_after_time = global_position + (velocity * sync_delta * smoothing_correction_range)
				var velocity_adj = expected_pos_after_time - true_pos_after_time
				velocity += velocity_adj
		last_sync_time = OS.get_ticks_msec()

var tick_count = 0
func _process(delta):
	if not static_display:
		var inside_planet = get_inside_planet()	#if we just stopped being inside a planet, trigger z switch
		if currently_inside_planet and not inside_planet:
			z_index = z_index * -1
		currently_inside_planet = inside_planet
		
		if docked():
			var my_port_relative = Global.json_to_vec(docked_from_port.relative_position)
			var station_port_relative = Global.json_to_vec(docked_to_port.relative_position)
			var rotation_offset = docked_to_port.relative_rotation + docked_from_port.relative_rotation
			global_rotation = docked_to_station.global_rotation + rotation_offset
			rotation_error = 0.0
			var docked_to_global_pos = docked_to_station.global_position + station_port_relative.rotated(docked_to_station.global_rotation)
			global_position = docked_to_global_pos + (my_port_relative * -1.0).rotated(global_rotation)
		else:
			if not is_zero_approx(rotation_error):
				if rotation_error > 0.0:
					if rotation_error > max_rotation_correction:
						current_rotation -= max_rotation_correction
						rotation_error -= max_rotation_correction
					else:
						current_rotation -= rotation_error
						rotation_error = 0.0
				else:
					if abs(rotation_error) > max_rotation_correction:
						current_rotation += max_rotation_correction
						rotation_error += max_rotation_correction
					else:
						current_rotation += rotation_error
						rotation_error = 0.0
			global_rotation = current_rotation
			global_position += velocity * delta
		tick_count += 1
	
func _physics_process(delta):
	if not static_display:
		if not docked():
			if tiller_left:
				current_rotation -= rotation_power * delta
			if tiller_right:
				current_rotation += rotation_power * delta
		var true_rotation = current_rotation - rotation_error
		if main_engines_active:
			velocity += Vector2(0,-main_engine_thrust).rotated(true_rotation) * delta
		if starboard_thrusters_active:
			velocity += Vector2(-manu_engine_thrust, 0).rotated(true_rotation) * delta
		if port_thrusters_active:
			velocity += Vector2(manu_engine_thrust, 0).rotated(true_rotation) * delta
		if fore_thrusters_active:
			velocity += Vector2(0, manu_engine_thrust).rotated(true_rotation) * delta
		if aft_thrusters_active:
			velocity += Vector2(0, -manu_engine_thrust).rotated(true_rotation) * delta
		var gravity_accel = Global.get_gravity_acceleration(global_position) * delta
		velocity += gravity_accel
	
var planet_cache = null
func get_inside_planet():
	if planet_cache == null:
		planet_cache = get_tree().get_nodes_in_group("Planets")
	
	var inside_any_planet = false
	for body in planet_cache:
		var body_position = body.global_position
		var min_alt_squared = pow(body.min_orbital_altitude,2)
		var r_squared = abs((body_position - global_position).length_squared())
		if(r_squared < min_alt_squared):
			return true
	return false
