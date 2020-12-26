extends Control

func _ready():
	pass

func init(json):
	var player_balance = json["player_balance"]
	var dealership_list = json["station_info"]["dealerships"]
	var dealership_menu = preload("res://scenes/menu/shipyard/DealershipMenu.tscn")
	print("Loading dealerships")
	for child in $TabContainer.get_children():
		$TabContainer.remove_child(child)
	for dealership_info in dealership_list:
		var inst = dealership_menu.instance()
		inst.init(dealership_info)
		$TabContainer.add_child(inst)
