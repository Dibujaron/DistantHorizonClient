extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var target_offset_distance = 1000

# need to do something special at zoom level 4.

export var pip_radius_medium = 50
export var scale_factor_base_medium = 0.1
export var threshold_medium = 4
export var frame_medium = 0

export var pip_radius_far = 0
export var scale_factor_base_far = 0.03
export var threshold_far = 8
export var frame_far = 1

var current_zoom = 0
var prior_global_rotation_degs = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	var ship_position = get_parent().global_position
	var zoom_level = Global.get_current_zoom()
	visible = zoom_level >= threshold_far
	var pip_radius = pip_radius_far
	var scale_factor_base = scale_factor_base_far
	var offset_direction = get_parent().global_rotation + PI
	var direction_vector = Vector2(cos(offset_direction), sin(offset_direction))
	var desired_offset = direction_vector * pip_radius
	var desired_position = ship_position + desired_offset
	var desired_rotation = direction_vector.angle()
	global_position = desired_position
	global_rotation = desired_rotation
	var new_scale_factor = scale_factor_base * zoom_level
	scale.x = new_scale_factor
	scale.y = new_scale_factor
