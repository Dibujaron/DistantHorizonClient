extends Area2D

var poi_text = ""

func _ready():
	add_to_group("ClickablePois")
	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			print("Clickable POI with text " + poi_text + " clicked.")
			if is_closest_poi():
				var poi_circle = Global.get_poi_circle()
				print("Setting poi circle with display text: " + poi_text)
				poi_circle.select_object(self, poi_text)
		elif event.button_index == BUTTON_RIGHT:
			print("Got right click.")
			var poi_circle = Global.get_poi_circle()
			poi_circle.stop_navigating()
		
func is_closest_poi():
	var mouse_pos = get_global_mouse_position()
	var all_pois = get_tree().get_nodes_in_group("ClickablePois")
	var self_distance = abs((global_position - mouse_pos).length_squared())
	for poi in all_pois:
		if poi != self:
			var poi_distance = abs((poi.global_position - mouse_pos).length_squared())
			if poi_distance < self_distance:
				return false
	return true
