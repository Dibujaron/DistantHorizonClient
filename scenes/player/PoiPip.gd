extends Node2D

export var pip_radius_close = 50
export var scale_factor_base_close = 0.07

export var pip_radius_medium = 300
export var scale_factor_base_medium = 0.03
export var threshold_medium = 2

export var pip_radius_far = 1000
export var scale_factor_base_far = 0.02
export var threshold_far = 8

var current_zoom = 0
var prior_global_rotation_degs = 0

#note when you change this file you should probably also change the very similar TargetingPip
func _process(delta):
	var ship_position = get_parent().global_position
	var poi_circle = Global.get_poi_circle()
	if poi_circle != null:
		if not poi_circle.is_enabled() or poi_circle.is_on_screen():
			hide()
		else:
			show()
			var zoom_level = Global.get_current_zoom()
			var pip_radius = zoom_level * 150
			var scale_factor_base = scale_factor_base_close
			if zoom_level >= threshold_medium:
				scale_factor_base = scale_factor_base_medium
				pip_radius = zoom_level * 40
			if zoom_level >= threshold_far:
				scale_factor_base = scale_factor_base_far
				pip_radius = zoom_level * 25
				
			var target_position = poi_circle.global_position
			var direction_vector = (target_position - ship_position).normalized()
			var desired_offset = direction_vector * pip_radius
			var desired_position = ship_position + desired_offset
			var desired_rotation = direction_vector.angle()
			global_position = desired_position
			global_rotation = desired_rotation
			var new_scale_factor = scale_factor_base * zoom_level
			scale.x = new_scale_factor
			scale.y = new_scale_factor

