extends Control
	
func init(ship_type_identifier, color1, color2):
	for child in get_children():
		remove_child(child)
	var ship_scene = Global.ship_scenes[ship_type_identifier]
	var displayed_ship = ship_scene.instance()
	displayed_ship._set_primary_color(color1)
	displayed_ship._set_secondary_color(color2)
	displayed_ship.scale = Vector2(4,4)
	displayed_ship.position = self.size / 2
	add_child(displayed_ship)
