extends "res://Orbiter.gd"

func _ready():
	pass

func json_init(station_info):
	.json_init(station_info)
	$AnimatedSprite.play("default")
	global_scale = Vector2(1.0, 1.0)

func json_update(station_info):
	.json_update(station_info)

func _process(delta):
	look_at(get_parent().global_position)

