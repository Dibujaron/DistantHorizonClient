extends Node2D

export var breadcrumb_interval_base = 1.0
export var calculation_steps_per_base_interval = 10.0
export var projections_to_keep = 20.0
var step_length = 1.0/60.0#breadcrumb_interval_base / calculation_steps_per_base_interval
var my_ship = null
var recent_projections = []
var target_position = Vector2(0,0)
var my_index = 0
func _ready():
	pass # Replace with function body.

func initialize(var index, var ship):
	my_index = index
	my_ship = ship

func _process(delta):
	global_rotation = 0
	var zoom = Global.get_current_zoom()

	global_scale.x = zoom
	global_scale.y = zoom
	var steps_to_project = breadcrumb_interval_base * my_index * calculation_steps_per_base_interval
	var position_projected = my_ship.global_position
	var velocity_projected = my_ship.velocity
	for i in range(0, steps_to_project):
		var ship_rotation = my_ship.global_rotation
		var main_engine_thrust = my_ship.main_engine_thrust
		var manu_engine_thrust = my_ship.manu_engine_thrust
		velocity_projected += Global.get_gravity_acceleration(position_projected) * step_length
		position_projected += velocity_projected * step_length
		
	recent_projections.push_front([position_projected, velocity_projected])
	if recent_projections.size() > projections_to_keep:
		recent_projections.pop_back()
	
	var sum_position = Vector2(0,0)
	var sum_velocity = Vector2(0,0)
	for proj in recent_projections:
		sum_position += proj[0]
		sum_velocity += proj[1]
	var avg_position = sum_position / recent_projections.size()
	var avg_velocity = sum_velocity / recent_projections.size()
	global_rotation = avg_velocity.angle()
	global_position = avg_position
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
