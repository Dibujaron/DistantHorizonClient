extends Node2D

export var calculation_steps = 6
export var projections_to_keep = 5
var step_length = 1.0/10.0#1.0/60.0

var recent_projections_pos = []
var recent_projections_vel = []
var target_position = Vector2(0,0)

var best_velocity = Vector2(0,0)
var best_position = Vector2(0,0)
var max_future_ticks = 0
func _process(_delta):
	var zoom = Global.get_current_zoom()

	global_scale.x = zoom
	global_scale.y = zoom
	var parent = get_parent()
	max_future_ticks = parent.max_future_ticks + (calculation_steps * step_length * 60)
	var position_projected = parent.best_position
	var velocity_projected = parent.best_velocity
	for i in range(0, calculation_steps):
		var future_distance_ticks = parent.max_future_ticks + (step_length * 60 * i)
		position_projected += velocity_projected * step_length
		var acceleration = Global.get_gravity_acceleration_at_tick(position_projected, future_distance_ticks) * step_length
		velocity_projected += acceleration
	recent_projections_pos.push_front(position_projected)
	if recent_projections_pos.size() > projections_to_keep:
		recent_projections_pos.pop_back()
	
	recent_projections_vel.push_front(velocity_projected)
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
	best_velocity = velocity_projected
	best_position = position_projected
	global_rotation = avg_velocity.angle()
	global_position = avg_position
