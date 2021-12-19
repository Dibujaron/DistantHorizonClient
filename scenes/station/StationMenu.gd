extends MarginContainer

var station_display_name
var station_desc
var menu_mode = "TRADE"
var vbox

func _ready():
	vbox = get_node("HBoxContainer/VBoxContainer")
	
func _depart_pressed():
	var client = get_tree().get_root().get_node("Space").get_node("WebSocketClient")
	client.undock()
	
func init(json):
	var station_info = json["station_info"]
	self.station_display_name = station_info["display_name"]
	self.station_desc = station_info["description"]
	vbox.get_node("HeaderLabel/StationName").text = station_display_name
	vbox.get_node("DescLabel/StationDesc").text = station_desc
	var tab_aligner = vbox.get_node("TabAligner")
	var tab_container = tab_aligner.get_node("TabContainer")
	var trade_menu = tab_container.get_node("Market")
	trade_menu.init(json)
	var fuel_menu = tab_container.get_node("Fuel")
	fuel_menu.init(json)
	for child in tab_container.get_children():
		if child.get_name() == "Shipyards":
			tab_container.remove_child(child)
	var shipyards_menu_scene = preload("res://scenes/menu/shipyard/ShipyardMenu.tscn")
	var shipyards_menu = shipyards_menu_scene.instance()
	shipyards_menu.init(json)
	shipyards_menu.set_name("Shipyards")
	if shipyards_menu.dealership_count > 0:
		tab_container.add_child(shipyards_menu)
	
