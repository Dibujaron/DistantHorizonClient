extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var id
var base_angular_velocity
var current_angular_velocity
var orbital_radius
var initialized = false
var expected_angular_pos
var expected_pos
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func json_init(orbiter_info):
	position = json_to_vec(orbiter_info["relative_pos"])
	base_angular_velocity = orbiter_info["angular_velocity"]
	print("angular velocity: ", base_angular_velocity)
	current_angular_velocity = base_angular_velocity
	orbital_radius = orbiter_info["orbital_radius"]
	print("initialized orbital radius to ", orbital_radius)
	json_update(orbiter_info)
	initialized = true

func json_update(orbiter_info):
	expected_angular_pos = orbiter_info["angular_pos"]
	expected_pos = json_to_vec(orbiter_info["relative_pos"])
	#var angular_pos = position.angle()
	#var expectation_diff = (expected_angular_pos + deg2rad(360))- (angular_pos + deg2rad(360))
	#todo PID
	#var corr_amt = deg2rad(0.005)
	#var corr_threshold = deg2rad(0.1)
	#if(expectation_diff > 0):
	#	current_angular_velocity = current_angular_velocity + corr_amt
	#elif(expectation_diff < 0):
	#	current_angular_velocity = current_angular_velocity - corr_amt
func json_to_vec(json):
	return Vector2(json["x"],json["y"])

func _physics_process(delta):
	if initialized and orbital_radius > 0:
		position = expected_pos
		#var pos_angle = position.angle()
		#var pos_angle = expected_angular_pos
		#var angle_offset = current_angular_velocity * delta
		#var new_angle = pos_angle + angle_offset
		#var new_pos = Vector2(cos(new_angle), sin(new_angle)) * orbital_radius
		#position = new_pos
