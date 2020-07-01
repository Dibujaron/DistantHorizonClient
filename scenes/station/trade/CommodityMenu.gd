extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var commodity_display_name = ""
var commodity_identifying_name
var trade_menu
var hold_contents
var commodity_info
var initialized = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(trade_menu, commodity_info, hold_contents):
	print("Initializing commodity menu")
	self.trade_menu = trade_menu
	self.hold_contents = hold_contents
	self.commodity_info = commodity_info
	self.commodity_display_name = commodity_info["display_name"]
	self.commodity_identifying_name = commodity_info["identifying_name"]
	if not initialized:
		print("has not been initialized before")
		get_node("HBoxContainer/Buy").connect("pressed", self, "_buy_pressed")
		get_node("HBoxContainer/Sell").connect("pressed", self, "_sell_pressed")
		var path = "res://sprites/items/" + self.commodity_identifying_name + ".png"
		get_node("HBoxContainer/CommodityBox/ImgContainer/ItemImg").texture = load(path)
	initialized = true
	draw()

func update():
	trade_menu.update()
	draw()
	
func draw():
	var hbox = get_node("HBoxContainer")
	
	var in_hold_ct = hbox.get_node("InHoldCt")
	var quantity_in_hold = hold_contents[commodity_identifying_name]
	in_hold_ct.text = str(quantity_in_hold)
	
	var commodity_box = hbox.get_node("CommodityBox")
	var commodity_label = commodity_box.get_node("Commodity")
	commodity_label.text = commodity_display_name	
	var commodity_price = commodity_box.get_node("Price")
	var price_val = commodity_info["price"]
	commodity_price.text = "$" + str(price_val)
	
	var for_sale_ct = hbox.get_node("ForSaleCt")
	var quantity_for_sale = commodity_info["quantity_available"]
	for_sale_ct.text = str(quantity_for_sale)
	
	
func _buy_pressed():
	buy(1)
	
func buy(desired_num):
	var client = get_tree().get_root().get_node("Space").get_node("WebSocketClient")
	client.purchase_from_station(commodity_identifying_name, desired_num)
	update()
	
func _sell_pressed():
	sell(1)

func sell(desired_num):
	var client = get_tree().get_root().get_node("Space").get_node("WebSocketClient")
	client.sell_to_station(commodity_identifying_name, desired_num)
	update()
