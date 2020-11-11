extends Node2D

export var breadcrumb_interval_base = 1.0
export var calculation_steps_per_base_interval = 10.0
export var projections_to_keep = 20
var step_length = breadcrumb_interval_base / calculation_steps_per_base_interval
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
		velocity_projected += Global.get_gravity_acceleration(position_projected) * delta
		position_projected += velocity_projected * delta
		
	recent_projections.push_front(position_projected)
	if recent_projections.size() > projections_to_keep:
		recent_projections.pop_back()
	
	var sum = Vector2(0,0)
	for proj in recent_projections:
		sum += proj
	var avg = sum / recent_projections.size()
	global_position = avg
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
