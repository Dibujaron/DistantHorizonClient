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
	var depart_button = get_node("HBoxContainer/VBoxContainer/DepartButton")
	depart_button.connect("pressed", self, "_depart_pressed") # Replace with function body. # Replace with function body.
	depart_button.hint_tooltip = "hotkey: [Esc]"
func _depart_pressed():
	var client = get_tree().get_root().get_node("Space").get_node("WebSocketClient")
	client.undock()
	
func init(json):
	self.player_balance = json["player_balance"]
	self.ship_hold_space = json["hold_space"]
	var station_info = json["station_info"]
	var hold_contents = json["hold_contents"]
	self.station_display_name = station_info["display_name"]
	self.station_desc = station_info["description"]

	for commodity_info in station_info["commodity_stores"]:
		var price = commodity_info["price"]
		if price > 0:
			instantiate_commodity_menu(commodity_info, hold_contents)
	get_node("HBoxContainer/VBoxContainer/PlayerBalance/CreditsBox").text = str(player_balance)
	get_node("HBoxContainer/VBoxContainer/PlayerHoldSpace/HoldSpaceBox").text = str(ship_hold_space)
	get_node("HBoxContainer/VBoxContainer/HeaderLabel/StationName").text = station_display_name
	get_node("HBoxContainer/VBoxContainer/DescLabel/StationDesc").text = station_desc
	
func instantiate_commodity_menu(commodity_info, hold_contents):
	var commodity_columns = get_node("HBoxContainer/VBoxContainer/CommodityColumns")
	commodity_columns.add_constant_override("separation", 30)
	for child in commodity_columns.get_children():
		child.add_constant_override("separation", 10)
		
	var commodity_identifying_name = commodity_info["identifying_name"]
	
	var itemIcon = commodity_columns.get_node("ItemCol/" + commodity_identifying_name)
	if itemIcon == null:
		itemIcon = load("res://CommodityIconInfo.tscn").instance()
		itemIcon.set_name(commodity_identifying_name)
		commodity_columns.get_node("ItemCol").add_child(itemIcon)
	itemIcon.init(commodity_info)
	var itemIconHeight = itemIcon.rect_size.y
	var inHoldCtBox = commodity_columns.get_node("OnShipCol/" + commodity_identifying_name)
	if inHoldCtBox == null:
		inHoldCtBox = Label.new()
		inHoldCtBox.rect_min_size = Vector2(0, itemIconHeight)
		inHoldCtBox.set_name(commodity_identifying_name)
		inHoldCtBox.valign = Label.ALIGN_CENTER
		inHoldCtBox.align = Label.ALIGN_RIGHT
		commodity_columns.get_node("OnShipCol").add_child(inHoldCtBox)
	var quantity_in_hold = hold_contents[commodity_identifying_name]
	inHoldCtBox.text = str(quantity_in_hold)
	
	var buyButton = commodity_columns.get_node("BuyCol/" + commodity_identifying_name)
	if buyButton == null:
		buyButton = load("res://BuyFromStationButton.tscn").instance()
		buyButton.set_name(commodity_identifying_name)
		buyButton.rect_min_size = Vector2(0, itemIconHeight)
		commodity_columns.get_node("BuyCol").add_child(buyButton)
	buyButton.init(commodity_identifying_name)
	
	var sellButton = commodity_columns.get_node("SellCol/" + commodity_identifying_name)
	if sellButton == null:
		sellButton = load("res://SellToStationButton.tscn").instance()
		sellButton.set_name(commodity_identifying_name)
		sellButton.rect_min_size = Vector2(0, itemIconHeight)
		commodity_columns.get_node("SellCol").add_child(sellButton)
	sellButton.init(commodity_identifying_name)

	var onStationCtBox = commodity_columns.get_node("OnStationCol/" + commodity_identifying_name)
	if onStationCtBox == null:
		onStationCtBox = Label.new()
		onStationCtBox.rect_min_size = Vector2(0, itemIconHeight)
		onStationCtBox.set_name(commodity_identifying_name)
		onStationCtBox.valign = Label.ALIGN_CENTER
		onStationCtBox.align = Label.ALIGN_RIGHT
		commodity_columns.get_node("OnStationCol").add_child(onStationCtBox)
	onStationCtBox.text = str(commodity_info["quantity_available"])
