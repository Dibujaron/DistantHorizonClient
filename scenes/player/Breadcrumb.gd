extends Node2D

export var breadcrumb_interval = 1.0
export var calculation_steps_per_interval = 10.0
export var projections_to_keep = 20
var step_length = breadcrumb_interval / calculation_steps_per_interval
var my_ship = null
var steps_to_project = 0
var recent_projections = []
var target_position = Vector2(0,0)
func _ready():
	pass # Replace with function body.

func initialize(var index, var ship):
	my_ship = ship
	steps_to_project = breadcrumb_interval * index * calculation_steps_per_interval

func _process(delta):
	var position_projected = my_ship.global_position
	var velocity_projected = my_ship.velocity
	for i in range(0, steps_to_project):
		var ship_rotation = my_ship.global_rotation
		var main_engine_thrust = my_ship.main_engine_thrust
		var manu_engine_thrust = my_ship.manu_engine_thrust
		if my_ship.main_engines_active:
			velocity_projected += Vector2(0,-main_engine_thrust).rotated(ship_rotation) * step_length
		if my_ship.starboard_thrusters_active:
			velocity_projected += Vector2(-manu_engine_thrust, 0).rotated(ship_rotation) * step_length
		if my_ship.port_thrusters_active:
			velocity_projected += Vector2(manu_engine_thrust, 0).rotated(ship_rotation) * step_length
		if my_ship.fore_thrusters_active:
			velocity_projected += Vector2(0, manu_engine_thrust).rotated(ship_rotation) * step_length
		if my_ship.aft_thrusters_active:
			velocity_projected += Vector2(0, -manu_engine_thrust).rotated(ship_rotation) * step_length
		velocity_projected += Global.get_gravity_acceleration(position_projected) * delta
		position_projected += velocity_projected * delta
		
	recent_projections.push_front(position_projected)
	if recent_projections.size() > projections_to_keep:
		recent_projections.pop_back()
	
	var sum = Vector2(0,0)
	for proj in recent_projections:
		sum += proj
	var recent_avg = sum / recent_projections.size()
	global_position = recent_avg
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
