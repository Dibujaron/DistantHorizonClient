extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var commodity_display_name = ""
var commodity_identifying_name
var trade_menu
var hold_contents
var commodity_info
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(trade_menu, commodity_info, hold_contents):
	self.trade_menu = trade_menu
	self.hold_contents = hold_contents
	self.commodity_info = commodity_info
	self.commodity_display_name = commodity_info["display_name"]
	self.commodity_identifying_name = commodity_info["identifying_name"]
	get_node("VBoxContainer/BuyBox/Buy1").connect("pressed", self, "_buy_1_pressed")
	get_node("VBoxContainer/BuyBox/Buy10").connect("pressed", self, "_buy_10_pressed")
	get_node("VBoxContainer/BuyBox/Buy100").connect("pressed", self, "_buy_100_pressed")
	get_node("VBoxContainer/SellBox/Sell1").connect("pressed", self, "_sell_1_pressed")
	get_node("VBoxContainer/SellBox/Sell10").connect("pressed", self, "_sell_10_pressed")
	get_node("VBoxContainer/SellBox/Sell100").connect("pressed", self, "_sell_100_pressed")
	draw()

func update():
	trade_menu.update()
	draw()
	
func draw():
	var vbox = get_node("VBoxContainer")
	var commodity_label = vbox.get_node("Commodity")
	commodity_label.text = commodity_display_name
	
	var in_hold_box = vbox.get_node("InHoldBox")
	var in_hold_ct = in_hold_box.get_node("InHoldCt")
	var quantity_in_hold = hold_contents[commodity_identifying_name]
	in_hold_ct.text = str(quantity_in_hold)
	
	var for_sale_box = vbox.get_node("ForSaleBox")
	var for_sale_ct = for_sale_box.get_node("ForSaleCt")
	var quantity_for_sale = commodity_info["quantity_available"]
	print("quantity available: ", quantity_for_sale)
	for_sale_ct.text = str(quantity_for_sale)
	
	var sell_box = vbox.get_node("SellBox")
	var sell_price_label = sell_box.get_node("SellPrice")
	var sell_price_val = commodity_info["sell_price"]
	sell_price_label.text = str(sell_price_val)
	
	var buy_box = vbox.get_node("BuyBox")
	var buy_price_label = buy_box.get_node("BuyPrice")
	var buy_price_val = commodity_info["buy_price"]
	buy_price_label.text = str(buy_price_val)
	
func _buy_1_pressed():
	buy(1)
	
func _buy_10_pressed():
	buy(10)
	
func _buy_100_pressed():
	buy(100)
	
func buy(desired_num):
	print("a")
	var client = get_tree().get_root().get_node("Space").get_node("WebSocketClient")
	print("b")
	client.purchase_from_station(commodity_identifying_name, desired_num)
	print("c")
	update()
	
func _sell_1_pressed():
	sell(1)
	
func _sell_10_pressed():
	sell(10)
	
func _sell_100_pressed():
	sell(100)

func sell(desired_num):
	var client = get_tree().get_root().get_node("Space").get_node("WebSocketClient")
	client.sell_to_station(commodity_identifying_name, desired_num)
	update()
	#update the UI
	update()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
