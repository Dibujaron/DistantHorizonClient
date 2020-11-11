extends Node2D

export var num_breadcrumbs = 5
var best_velocity = Vector2(0,0)
func _ready():
	var breadcrumb_scene = preload("res://scenes/player/Breadcrumb.tscn")
	var last_parent = self
	for i in range(0, num_breadcrumbs):
		var breadcrumb = breadcrumb_scene.instance()
		last_parent.add_child(breadcrumb)
		last_parent = breadcrumb
		
func _process(delta):
	best_velocity = get_parent().velocity
