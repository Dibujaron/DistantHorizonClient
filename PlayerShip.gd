extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var rotation_increment = 0.10
export var main_engine_thrust = 2.0
export var manu_engine_thrust = 0.5
export var mass = 2030000
export var gravity_constant_base = 6.67408
export var gravity_constant_exp = -11
export var initial_velocity = Vector2(-300, -300)
export var dock_min_dist = 50 
export var zoom_factor = 0.5
var start_position
var gravity_constant
var velocity = Vector2()

var main_engines
var port_thrusters
var starboard_thrusters
var fore_thrusters
var aft_thrusters
var docking_ports

var main_engines_active = false
var port_thrusters_active = false
var starboard_thrusters_active = false
var fore_thrusters_active = false
var aft_thrusters_active = false
var docked = false
var currently_inside_planet = false
# Called when the node enters the scene tree for the first time.
func _ready():
	
	main_engines = [get_node("EngineP"), get_node("EngineC"), get_node("EngineS")]
	port_thrusters = [get_node("ManuPF"), get_node("ManuPA")]
	starboard_thrusters = [get_node("ManuSF"), get_node("ManuSA")]
	fore_thrusters = [get_node("ManuFP"), get_node("ManuFS")]
	aft_thrusters = [get_node("ManuAP"), get_node("ManuAS")]
	docking_ports = [get_node("DockPortP"), get_node("DockPortS")]
	$AnimatedSprite.play("base")
	gravity_constant = gravity_constant_base * pow(10, gravity_constant_exp)
	start_position = global_position
	velocity = initial_velocity

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_in()
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_out()
			
			

func _process(delta):
	process_input()
	process_thrusters()
	if not docked:
		velocity = velocity + get_gravity_acceleration()
		position += velocity * delta

func process_input():
	if Input.is_action_just_pressed("ui_zoom_in"):
		zoom_in()
	if Input.is_action_just_pressed("ui_zoom_out"):
		zoom_out()
	if Input.is_action_pressed("ui_reset"):
		global_position = start_position
		velocity = initial_velocity
		main_engines_active = false
	if not docked:
		if Input.is_action_pressed("ui_rotate_right"):
			rotation = rotation + rotation_increment
		if Input.is_action_pressed("ui_rotate_left"):
			rotation = rotation -rotation_increment
	if Input.is_action_pressed("ui_fire_engines"):
		enable_engines()
	else:
		disable_engines()
	if Input.is_action_pressed("ui_strafe_left"):
		enable_starboard_thrusters()
	else:
		disable_starboard_thrusters()
	if Input.is_action_pressed("ui_strafe_right"):
		enable_port_thrusters()
	else:
		disable_port_thrusters()
	if Input.is_action_pressed("ui_strafe_forward"):
		enable_aft_thrusters()
	else:
		disable_aft_thrusters()
	if Input.is_action_pressed("ui_strafe_backward"):
		enable_fore_thrusters()
	else:
		disable_fore_thrusters()
		
	if Input.is_action_just_pressed("ui_dock"):
		if docked:
			undock()
		else:
			attempt_dock()
			
func process_thrusters():
	if main_engines_active:
		velocity += Vector2(0,-main_engine_thrust).rotated(rotation)
	if starboard_thrusters_active:
		velocity += Vector2(-manu_engine_thrust, 0).rotated(rotation)
	if port_thrusters_active:
		velocity += Vector2(manu_engine_thrust, 0).rotated(rotation)
	if fore_thrusters_active:
		velocity += Vector2(0, manu_engine_thrust).rotated(rotation)
	if aft_thrusters_active:
		velocity += Vector2(0, -manu_engine_thrust).rotated(rotation)
		
func get_gravity_acceleration():
	var total_acceleration = Vector2()
	var bodies = get_tree().get_nodes_in_group("OrbitingBodies")
	
	var inside_any_planet = false
	for body in bodies:
		var body_mass = body.get_mass()
		var body_position = body.global_position
		var r_squared = abs((body_position - global_position).length_squared())
		var min_alt_squared = pow(body.get_min_orbital_altitude(),2)
		if(r_squared < min_alt_squared):
			r_squared = min_alt_squared
			inside_any_planet = true
		var f_magnitude = gravity_constant * body_mass / r_squared
		var acceleration = (body_position - position).normalized() * f_magnitude
		total_acceleration = total_acceleration + acceleration
	
	#if we just stopped being inside a planet, trigger z switch
	if currently_inside_planet and not inside_any_planet:
		z_index = z_index * -1
	currently_inside_planet = inside_any_planet
	
	return total_acceleration
		
func enable_engines():
	if(not main_engines_active):
		main_engines_active = true
		for engine in main_engines:
			engine.enable()
	
func disable_engines():
	if(main_engines_active):
		main_engines_active = false
		for engine in main_engines:
			engine.disable()

func enable_port_thrusters():
	if(not port_thrusters_active):
		port_thrusters_active = true
		for engine in port_thrusters:
			engine.enable()
	
func disable_port_thrusters():
	if(port_thrusters_active):
		port_thrusters_active = false
		for engine in port_thrusters:
			engine.disable()
			
func enable_starboard_thrusters():
	if(not starboard_thrusters_active):
		starboard_thrusters_active = true
		for engine in starboard_thrusters:
			engine.enable()
	
func disable_starboard_thrusters():
	if(starboard_thrusters_active):
		starboard_thrusters_active = false
		for engine in starboard_thrusters:
			engine.disable()
			
func enable_fore_thrusters():
	if(not fore_thrusters_active):
		fore_thrusters_active = true
		for engine in fore_thrusters:
			engine.enable()
	
func disable_fore_thrusters():
	if(fore_thrusters_active):
		fore_thrusters_active = false
		for engine in fore_thrusters:
			engine.disable()
			
func enable_aft_thrusters():
	if(not aft_thrusters_active):
		aft_thrusters_active = true
		for engine in aft_thrusters:
			engine.enable()
	
func disable_aft_thrusters():
	if(aft_thrusters_active):
		aft_thrusters_active = false
		for engine in aft_thrusters:
			engine.disable()
	
func zoom_in():
	var camera = $Camera2D
	if camera.zoom.x > 0.5:
		camera.zoom = camera.zoom * zoom_factor	
		var new_zoom = camera.zoom.x
		var parallax_bg = get_tree().get_root().get_node("Space").get_node("ParallaxBackground")
		#parallax_bg.get_node("LayerTop").motion_scale *= zoom_factor
		#parallax_bg.get_node("LayerMiddle").motion_scale *= zoom_factor
		#parallax_bg.get_node("LayerLower").motion_scale *= zoom_factor
		if new_zoom <= 2:
			parallax_bg.get_node("LayerTop").show()
		if new_zoom <= 4:
			parallax_bg.get_node("LayerMiddle").show()
		if new_zoom <= 8:
			parallax_bg.get_node("LayerLower").show()
		print("camera zoom is ", camera.zoom)

func zoom_out():
	var camera = $Camera2D
	if camera.zoom.x < 64:
		camera.zoom = camera.zoom / zoom_factor
		var parallax_bg = get_tree().get_root().get_node("Space").get_node("ParallaxBackground")
		#parallax_bg.get_node("LayerTop").motion_scale /= zoom_factor
		#parallax_bg.get_node("LayerMiddle").motion_scale /= zoom_factor
		#parallax_bg.get_node("LayerLower").motion_scale /= zoom_factor
		var new_zoom = camera.zoom.x
		if new_zoom > 2:
			parallax_bg.get_node("LayerTop").hide()
		if new_zoom > 4:
			parallax_bg.get_node("LayerMiddle").hide()
		if new_zoom > 8:
			parallax_bg.get_node("LayerLower").hide()
		print("camera zoom is ", camera.zoom)
func undock():
	docked = false
	for port in docking_ports:
		port.undock()
		
func attempt_dock():
	var min_dist_squared = pow(dock_min_dist,2)
	var best_port
	var best_dist = min_dist_squared
	
	for port in docking_ports:
		var dist = port.get_best_dock_dist(dock_min_dist)
		if(dist < best_dist):
			best_port = port
			best_dist = dist
	
	if best_dist < min_dist_squared:
		print("best docking distance: ", sqrt(best_dist), " is within range.")
		var success = best_port.dock(dock_min_dist)
		if success:
			docked = true
	else:
		print("no docks in range.")
		
func get_best_dock_dist(dock_threshold):
	var all_ports = get_tree().get_nodes_in_group("DockingPortsFemale")
	var dock_threshold_squared = dock_threshold * dock_threshold
	var best_dist_squared = dock_threshold_squared #it'll never be more than this
	for port in all_ports:
		var other_position = port.global_position
		var my_position = global_position
		var dist_squared = (my_position - other_position).length_squared()
		if dist_squared < best_dist_squared:
			best_dist_squared = dist_squared
	return best_dist_squared
	
func get_velocity():
	return velocity

func set_velocity(new_velocity):
	velocity = new_velocity
