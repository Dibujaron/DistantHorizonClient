extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player_acct
var ship_hold
var station_name
var station_desc
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(station_name, station_desc, station_hold, ship_hold, player_acct):
	self.player_acct = player_acct
	self.station_name = station_name
	self.station_desc = station_desc
	self.ship_hold = ship_hold

	for commodity in station_hold.commodities_map.keys():
		var amount_in_hold = station_hold.commodities_map[commodity]
		var buy_price = station_hold.commodity_buy_prices[commodity]
		var sell_price = station_hold.commodity_sell_prices[commodity]
		if (amount_in_hold > 0 and buy_price < 9999):
			instantiate_commodity_menu(commodity, station_hold)
	
	for commodity in station_hold.commodities_map.keys():
		var sell_price = station_hold.commodity_sell_prices[commodity]
		if sell_price > 0:
			instantiate_commodity_menu(commodity, station_hold)
	update() 
	
func instantiate_commodity_menu(commodity, station_hold):
	var menu_scene = load("res://CommodityMenu.tscn")
	var vbox = get_node("HBoxContainer/VBoxContainer")
	var menu_for_commodity = menu_scene.instance()
	menu_for_commodity.set_name(commodity + "Menu")
	vbox.add_child(menu_for_commodity)
	menu_for_commodity.init(self, commodity, station_hold, ship_hold, player_acct)
	
func update():
	draw()

func draw():
	get_node("HBoxContainer/VBoxContainer/PlayerBalance/CreditsBox").text = str(player_acct.balance())
	get_node("HBoxContainer/VBoxContainer/PlayerHoldSpace/HoldSpaceBox").text = str(ship_hold.available_space())
	get_node("HBoxContainer/VBoxContainer/HeaderLabel/StationName").text = station_name
	get_node("HBoxContainer/VBoxContainer/DescLabel/StationDesc").text = station_desc
#func _process(delta):
#	pass
