extends "res://scenes/orbiter/Orbiter.gd"

var display_name
var shows_on_navigation = true
func _ready():
	add_to_group("Stations")

func json_init(station_info):
	.json_init(station_info)
	display_name = station_info["display_name"]
	shows_on_navigation = station_info["navigable"]
	if not shows_on_navigation:
		print("station doesn't show")
	$AnimatedSprite.play("default")
	global_scale = Vector2(1.0, 1.0)

func json_update(station_info):
	.json_update(station_info)

func _process(delta):
	look_at(get_parent().global_position)

func globalRotationAtTime(time):
	var vecToParentAtTime = relativePosAtTime(time) * -1.0
	return vecToParentAtTime.angle()
