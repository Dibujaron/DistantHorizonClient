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
var rotating_left = false
var rotating_right = false

var velocity = Vector2(0,0)
var expected_position = Vector2(0,0)

var initialized = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("base")

func json_init(json):
	global_position = json_to_vec(json["global_pos"])
	json_update(json)
	initialized = true
	
func json_update(json):
	rotation = json["rotation"]
	main_engines_active = json["main_engines"]
	port_thrusters_active = json["port_thrusters"]
	starboard_thrusters_active = json["stbd_thrusters"]
	fore_thrusters_active = json["fore_thrusters"]
	aft_thrusters_active = json["aft_thrusters"]
	rotating_left = json["rotating_left"]
	rotating_right = json["rotating_right"]
	expected_position = json_to_vec(json["global_pos"])
	var server_velocity = json_to_vec(json["velocity"])
	#we want to set our velocity so that position in a second is the same
	#var expect_pos_in_sec = expected_position + server_velocity
	#var required_velocity = expect_pos_in_sec - global_position
	#velocity = required_velocity
	velocity = server_velocity
	
	#update engines
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
	
func json_to_vec(json):
	return Vector2(json["x"],json["y"])
	
func _physics_process(delta):
	if initialized:
		global_position = expected_position
		#global_position += velocity * delta
	#position = stored_position
