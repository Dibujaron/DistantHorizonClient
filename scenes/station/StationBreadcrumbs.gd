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
	var targeting_circle = get_parent()
	var on_screen = targeting_circle.is_on_screen()
	if not on_screen:
		hide()
	else:
		show()
		var station = targeting_circle.get_parent()
		best_velocity = station.linear_velocity()
		best_position = station.global_position
