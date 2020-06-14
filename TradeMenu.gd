extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player_balance
var ship_hold_space
var station_display_name
var station_desc
var commodity_menu_count
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(json):
	self.player_balance = json["player_balance"]
	self.ship_hold_space = json["hold_space"]
	var station_info = json["station_info"]
	var hold_contents = json["hold_contents"]
	self.station_display_name = station_info["display_name"]
	self.station_desc = station_info["description"]

	commodity_menu_count = 0
	for commodity_info in station_info["commodity_stores"]:
		var buy_price = commodity_info["buy_price"]
		if (buy_price < 9999):
			instantiate_commodity_menu(commodity_info, hold_contents)
	
	for commodity_info in station_info["commodity_stores"]:
		var sell_price = commodity_info["sell_price"]
		if sell_price > 0:
			instantiate_commodity_menu(commodity_info, hold_contents)
	update() 
	
func instantiate_commodity_menu(commodity_info, hold_contents):
	var menu_scene = load("res://CommodityMenu.tscn")
	var vbox = get_node("HBoxContainer/VBoxContainer")
	if commodity_menu_count > 5:
		vbox = get_node("HBoxContainer/VBoxContainer2")
	var menu_name = commodity_info["identifying_name"] + "Menu"
	var menu_for_commodity = vbox.get_node(menu_name)
	if not menu_for_commodity:
		menu_for_commodity = menu_scene.instance()
		menu_for_commodity.set_name(menu_name)
		vbox.add_child(menu_for_commodity)
	commodity_menu_count += 1
	menu_for_commodity.init(self, commodity_info, hold_contents)
	
func update():
	draw()

func draw():
	get_node("HBoxContainer/VBoxContainer/PlayerBalance/CreditsBox").text = str(player_balance)
	get_node("HBoxContainer/VBoxContainer/PlayerHoldSpace/HoldSpaceBox").text = str(ship_hold_space)
	get_node("HBoxContainer/VBoxContainer/HeaderLabel/StationName").text = station_display_name
	get_node("HBoxContainer/VBoxContainer/DescLabel/StationDesc").text = station_desc
#func _process(delta):
#	pass
