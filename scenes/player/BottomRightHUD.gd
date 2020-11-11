extends VBoxContainer

var linked_ship = null
export var update_every_n_ticks = 60

func link_ship(ship):
	if linked_ship:
		print("error attempted to link ship to HUD but already linked.")
		print("existing ship: ", linked_ship)
		print("new ship: ", ship)
	else:
		print("linked ship to hud.")
		linked_ship = ship
		
func get_linked_ship():
	return linked_ship

var ticks_since_update = 0
var enabled = false
func _process(delta):
	var targeting_circle = Global.get_targeting_circle()
	var should_be_enabled = targeting_circle != null and targeting_circle.is_enabled()
	if enabled != should_be_enabled or ticks_since_update >= update_every_n_ticks:
		do_update(targeting_circle)
		enabled = should_be_enabled
		ticks_since_update = 0
	ticks_since_update += 1
	
func do_update(targeting_circle):
	var target_dist_label = $DistToTargetLabel
	if targeting_circle and targeting_circle.is_enabled() and get_linked_ship():
		var offset = targeting_circle.global_position - get_linked_ship().global_position
		var dist = offset.length()
		target_dist_label.text = "Distance to target: " + Global.pretty_print_distance(dist)
	else:
		target_dist_label.text = ""
