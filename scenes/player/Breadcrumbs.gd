extends Node2D

export var num_breadcrumbs = 5

func initialize(ship):
	var breadcrumb_scene = preload("res://scenes/player/Breadcrumb.tscn")
	for i in range(0, num_breadcrumbs):
		var breadcrumb = breadcrumb_scene.instance()
		add_child(breadcrumb)
		breadcrumb.initialize(i, ship)
