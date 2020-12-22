extends Node2D

export var num_breadcrumbs = 5
var best_velocity = Vector2(0,0)
var best_position = Vector2(0,0)

#todo use relative position to avoid jitter
func _ready():
	var breadcrumb_scene = preload("res://scenes/player/Breadcrumb.tscn")
	var last_parent = self
	for i in range(0, num_breadcrumbs):
		var breadcrumb = breadcrumb_scene.instance()
		last_parent.add_child(breadcrumb)
		last_parent = breadcrumb
		
func _process(delta):
	var ship = get_parent()
	visible = not ship.docked()
	best_velocity = ship.velocity
	best_position = ship.global_position
