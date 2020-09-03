extends GridContainer

var linked_ship = null

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
