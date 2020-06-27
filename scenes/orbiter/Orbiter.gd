extends Node2D

var orbiter_name
var base_angular_velocity
var current_angular_velocity
var orbital_radius
var initialized = false
var expected_angular_pos
var expected_pos
const PIDController = preload("res://scenes/orbiter/PIDController.tscn")
var velocity_controller = PIDController.instance()
var last_update = 0.0
func _ready():
	add_child(velocity_controller)
	velocity_controller._Kp = 0.5#0.5#0.1
	velocity_controller._Kd = 0.25#0.1
	velocity_controller._Ki = 0.05#0.5 
	
func json_init(orbiter_info):
	orbiter_name = orbiter_info["name"]
	position = json_to_vec(orbiter_info["relative_pos"])
	base_angular_velocity = float(orbiter_info["angular_velocity"])
	current_angular_velocity = base_angular_velocity
	orbital_radius = orbiter_info["orbital_radius"]
	json_update(orbiter_info)
	initialized = true

func json_update(orbiter_info):
	var current_time = OS.get_ticks_msec() / 1000.0
	var elapsed_time = current_time - last_update
	expected_angular_pos = orbiter_info["angular_pos"]
	var angular_pos = position.angle()
	var current_error = Global.angular_diff(expected_angular_pos, angular_pos)
	if(orbiter_name == "Stn_Innerstellar Launch" && OS.get_ticks_msec() % 10000 == 0):
		print("angular error: ", rad2deg(current_error))
	if elapsed_time > 0:
		var delta = velocity_controller.calculate(current_error, elapsed_time)
		current_angular_velocity = base_angular_velocity + delta
	last_update = OS.get_ticks_msec() / 1000.0
	
	
func json_to_vec(json):
	return Vector2(json["x"],json["y"])
	
func _process(delta):
	if initialized and orbital_radius > 0:
		var angle_offset = current_angular_velocity * delta
		position = position.rotated(angle_offset)
