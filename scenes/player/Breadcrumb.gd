extends Node2D

export var projections_to_keep = 10

var recent_projections_pos = []
var recent_projections_vel = []
var projected_position = Vector2(0,0)
var projected_velocity = Vector2(0,0)
func _process(_delta):
	var zoom = Global.get_current_zoom()
	global_scale.x = zoom
	global_scale.y = zoom
	recent_projections_pos.push_front(projected_position)
	if recent_projections_pos.size() > projections_to_keep:
		recent_projections_pos.pop_back()
	
	recent_projections_vel.push_front(projected_velocity)
	if recent_projections_vel.size() > projections_to_keep:
		recent_projections_vel.pop_back()
		
	var sum_position = Vector2(0,0)
	var sum_velocity = Vector2(0,0)
	for proj_pos in recent_projections_pos:
		sum_position += proj_pos
	
	for proj_vel in recent_projections_vel:
		sum_velocity += proj_vel
		
	var avg_position = sum_position / recent_projections_pos.size()
	var avg_velocity = sum_velocity / recent_projections_vel.size()
	global_position = avg_position
	global_rotation = avg_velocity.angle()
