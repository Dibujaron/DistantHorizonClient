extends Node2D

export var num_breadcrumbs = 5

export var calculation_step_length_seconds = 1.0/10.0
export var calculation_steps_per_breadcrumb = 6
var breadcrumbs = []
func _ready():
	var breadcrumb_scene = preload("res://scenes/player/Breadcrumb.tscn")
	for _i in range(0, num_breadcrumbs):
		var breadcrumb = breadcrumb_scene.instance()
		add_child(breadcrumb)
		breadcrumbs.append(breadcrumb)
		
func _process(_delta):
	var ship = get_parent()
	visible = not ship.docked()
	
	var seconds_in_future = 0.0
	var projected_position = ship.global_position
	var projected_velocity = ship.velocity
	
	for breadcrumb_index in range(0, num_breadcrumbs):
		var breadcrumb = breadcrumbs[breadcrumb_index]
		for calculation_step_index in range(0, calculation_steps_per_breadcrumb):
			seconds_in_future += calculation_step_length_seconds
			projected_position += (projected_velocity * calculation_step_length_seconds)
			var ticks_in_future = seconds_in_future / 60.0
			var acceleration = Global.get_gravity_acceleration_at_tick(projected_position, ticks_in_future) * calculation_step_length_seconds
			projected_velocity += acceleration
		breadcrumb.projected_position = Vector2(projected_position.x, projected_position.y)
		breadcrumb.projected_velocity = Vector2(projected_velocity.x, projected_velocity.y)
