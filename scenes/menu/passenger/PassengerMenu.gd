extends VBoxContainer

var selected_group = null

func _ready():
	var _connect_result = $ButtonHolder/Load1Button.connect("pressed", self, "_load_one")
	var _connect_result2 = $ButtonHolder/Load10Button.connect("pressed", self, "_load_ten")
	var _connect_result3 = $ButtonHolder/LoadAllButton.connect("pressed", self, "_load_all")

func init(json):
	$PassengerCapacityField.set_field_value(str(json["passenger_space"]))
	var selected_group_destination = null
	if selected_group != null:
		selected_group_destination = selected_group.destination
	un_select_group()
	Global.delete_children($WaitingPassengerGroupHolder)
	var waiting_group_scene = preload("res://scenes/menu/passenger/WaitingPassengerGroup.tscn")
	var station_info = json["station_info"]
	var waiting_passengers_unsorted = station_info["waiting_passengers"]
	var waiting_passengers_sorted = waiting_passengers_unsorted.sort_custom(self, "sort_by_distance")
	for waiting_passenger_group in station_info["waiting_passengers"]:
		var group = waiting_group_scene.instance()
		$WaitingPassengerGroupHolder.add_child(group)
		group.init(waiting_passenger_group)
		if (selected_group_destination != null) && (selected_group_destination == group.destination):
			select_group(group)
	
func select_group(waiting_group):
	if selected_group != null:
		selected_group.set_selected(false)
	waiting_group.set_selected(true)
	selected_group = waiting_group
	$ButtonHolder/Load10Button.disabled = false
	$ButtonHolder/Load1Button.disabled = false
	$ButtonHolder/LoadAllButton.disabled = false
	
func un_select_group():
	if selected_group != null:
		selected_group.set_selected(false)
		selected_group = null
		$ButtonHolder/Load10Button.disabled = true
		$ButtonHolder/Load1Button.disabled = true
		$ButtonHolder/LoadAllButton.disabled = true
		
func _load_one():
	load_passengers(1)

func _load_ten():
	load_passengers(10)
	
func _load_all():
	load_passengers(selected_group.quantity)
	
func load_passengers(quantity):
	var destination = selected_group.destination
	Global.get_socket_client().load_passengers(destination, quantity)

func sort_by_distance(group_a, group_b):
	var station_a = Global.get_station_by_name(group_a["destination_station"])
	var station_b = Global.get_station_by_name(group_b["destination_station"])
	var vec_a = station_a.get_offset_vector_from_player()
	var vec_b = station_b.get_offset_vector_from_player()
	var dist_a = vec_a.length_squared()
	var dist_b = vec_b.length_squared()
	return dist_a < dist_b
