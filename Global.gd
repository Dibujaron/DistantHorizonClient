extends Node

var chosenPrimaryColor: Color = Color.blue
var chosenSecondaryColor: Color = Color.white

export var gravity_constant_fudge = 10.0
export var gravity_constant_base = 6.67408
export var gravity_constant_exp = -11.0
var gravity_constant = gravity_constant_base * pow(10, gravity_constant_exp) * gravity_constant_fudge
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func angular_diff(a, b):
	var vecA = polar2cartesian(1, a)
	var vecB = polar2cartesian(1, b)
	return vecB.angle_to(vecA)
	
#func angular_diff(a, b):
	#var diff = rad2deg(b) - rad2deg(a)
	#var res = diff if abs(diff) < 180 else diff + (360 * -sign(diff))
	#return deg2rad(res)
	
func json_to_vec(json):
	return Vector2(json["x"],json["y"])

func json_to_color(json):
	return Color8(json["r"], json["g"], json["b"])
	
func get_gravity_acceleration(pos):
	var total_acceleration = Vector2()
	var bodies = get_tree().get_nodes_in_group("Planets")
	
	var inside_any_planet = false
	for body in bodies:
		var body_mass = body.mass
		var body_position = body.global_position
		var r_squared = abs((body_position - pos).length_squared())
		var f_magnitude = gravity_constant * body_mass / r_squared
		var acceleration = (body_position - pos).normalized() * f_magnitude
		total_acceleration = total_acceleration + acceleration
	return total_acceleration
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
