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
	$ClickablePoi.poi_text = display_name
	
func json_update(station_info):
	.json_update(station_info)

func _process(_delta):
	look_at(get_parent().global_position)

func global_rotation_at_time(time):
	var vecToParentAtTime = relative_pos_at_time(time) * -1.0
	return vecToParentAtTime.angle()
	
func get_offset_vector_from_player():
	var stn_position = global_position
	var player = Global.get_primary_player()
	var player_position = player.global_position
	return (stn_position - player_position)
