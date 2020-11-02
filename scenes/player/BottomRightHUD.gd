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
func _process(delta):
	if ticks_since_update >= update_every_n_ticks:
		update()
		ticks_since_update = 0
	ticks_since_update += 1
func update():
	var target_dist_label = $DistToTargetLabel
	var targeting_circle = Global.get_targeting_circle()
	if targeting_circle != null and targeting_circle.is_enabled():
		var offset = targeting_circle.global_position - get_linked_ship().global_position
		var dist = offset.length()
		target_dist_label.text = "Distance to target: " + Global.pretty_print_distance(dist)
	else:
		target_dist_label.text = ""
