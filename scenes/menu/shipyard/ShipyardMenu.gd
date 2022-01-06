extends Control

func _ready():
	pass

var dealership_count = 0

func init(json):
	#var player_balance = json["player_balance"]
	var dealership_list = json["station_info"]["dealerships"]
	var dealership_menu = preload("res://scenes/menu/shipyard/DealershipMenu.tscn")
	print("Loading dealerships")
	dealership_count = 0
	Global.delete_children($TabContainer)
	for dealership_info in dealership_list:
		var inst = dealership_menu.instance()
		inst.init(dealership_info, $NameShipPopup)
		$TabContainer.add_child(inst)
		dealership_count = dealership_count + 1
