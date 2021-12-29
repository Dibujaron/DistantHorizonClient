extends "res://scenes/orbiter/Orbiter.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rotation_speed = 0
var tidal_lock = false
var type = "Star"
var mass = 0
var min_orbital_altitude = 0
var min_orbital_altitude_squared = 0
var display_name
func get_mass():
	return mass
	
func _ready():
	add_to_group("Planets")

func json_init(planet_info):
	.json_init(planet_info)
	rotation_speed = planet_info["rotation_speed"]
	tidal_lock = planet_info["tidal_lock"]
	mass = planet_info["mass"]
	display_name = planet_info["display_name"]
	min_orbital_altitude = planet_info["min_orbital_altitude"]
	min_orbital_altitude_squared = min_orbital_altitude * min_orbital_altitude
	var new_type = planet_info["type"]
	if new_type != type:
		type = new_type
		$ScalableHolder/AnimatedSprite.play(type)
	var scale_fac = planet_info["scale"]
	var planet_scale = Vector2(scale_fac, scale_fac)
	if is_inside_tree():
		$ScalableHolder.global_scale = planet_scale
	else: 
		$ScalableHolder.scale = planet_scale
	$ScalableHolder/ClickablePoi.poi_text = display_name


func json_update(planet_info):
	.json_update(planet_info)
	
func _process(_delta):
	var top_parent = get_top_parent()
	if top_parent != self:
		$ScalableHolder.look_at(top_parent.global_position)

func json_to_vec(json):
	return Vector2(json["x"],json["y"])
