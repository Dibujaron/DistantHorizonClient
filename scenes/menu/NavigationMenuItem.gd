extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var station = null
var stn_name = null
var parent_menu = null


func init(parent, station_name):
	stn_name = station_name
	parent_menu = parent
	station = Global.get_space().stations[station_name]
	update()
	
func do_update():
	if station != null:
		var player_ship = Global.get_primary_player_ship()
		if player_ship and player_ship.docked() and player_ship.docked_to_station == station:
			hide()
		else:
			show()
		$StationNameVal.text = station.display_name
		var stn_position = station.global_position
		var player = Global.get_primary_player()
		var player_position = player.global_position
		var distance = get_distance()
		$DistanceVal.text = Global.pretty_print_distance(distance)
		
func get_distance():
	return get_offset_vector().length()
	
func get_dist_squared():
	return get_offset_vector().length_squared()
	
func get_offset_vector():
	var stn_position = station.global_position
	var player = Global.get_primary_player()
	var player_position = player.global_position
	return (stn_position - player_position)
	
func on_selected():
	parent_menu.on_navigation_selected(stn_name)
