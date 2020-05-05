extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var commodity_name = ""
var station_hold
var ship_hold
var player_acct
var trade_menu
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(trade_menu, commodity_name, station_hold, ship_hold, player_acct):
	self.trade_menu = trade_menu
	self.commodity_name = commodity_name
	self.station_hold = station_hold
	self.ship_hold = ship_hold
	self.player_acct = player_acct
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
	commodity_label.text = commodity_name
	
	var in_hold_box = vbox.get_node("InHoldBox")
	var in_hold_ct = in_hold_box.get_node("InHoldCt")
	var quantity_in_hold = ship_hold.get_amt(commodity_name)
	in_hold_ct.text = str(quantity_in_hold)
	
	var for_sale_box = vbox.get_node("ForSaleBox")
	var for_sale_ct = for_sale_box.get_node("ForSaleCt")
	var quantity_for_sale = station_hold.get_amt(commodity_name)
	for_sale_ct.text = str(quantity_for_sale)
	
	var sell_box = vbox.get_node("SellBox")
	var sell_price_label = sell_box.get_node("SellPrice")
	var sell_price_val = station_hold.sell_to_me_price(commodity_name)
	sell_price_label.text = str(sell_price_val)
	
	var buy_box = vbox.get_node("BuyBox")
	var buy_price_label = buy_box.get_node("BuyPrice")
	var buy_price_val = station_hold.buy_from_me_price(commodity_name)
	buy_price_label.text = str(buy_price_val)
	
func _buy_1_pressed():
	buy(1)
	
func _buy_10_pressed():
	buy(10)
	
func _buy_100_pressed():
	buy(100)
	
func buy(desired_num):
	var per_each_price = station_hold.buy_from_me_price(commodity_name)
	
	var purchase_qty = desired_num
	
	#validations
	#first check if there's enough on the station
	var available_qty = station_hold.get_amt(commodity_name)
	if purchase_qty > available_qty:
		purchase_qty = available_qty
	
	#now check if there's room in the hold
	var space_in_hold = ship_hold.available_space()
	if (purchase_qty > space_in_hold):
		purchase_qty = space_in_hold
		
	#now check if we can afford it
	var total_price = per_each_price * purchase_qty
	var available_balance = player_acct.balance()
	if total_price > available_balance:
		var affordable_quantity = floor(available_balance / per_each_price)
		purchase_qty = affordable_quantity
		total_price = per_each_price * affordable_quantity
	
	#now do it
	player_acct.add(-total_price)
	station_hold.add(commodity_name, -purchase_qty)
	ship_hold.add(commodity_name, purchase_qty)
	print("bought ", purchase_qty, " of ", commodity_name, " for ", total_price)
	print("player has ", player_acct.balance())
	#update the UI
	update()
	
func _sell_1_pressed():
	sell(1)
	
func _sell_10_pressed():
	sell(10)
	
func _sell_100_pressed():
	sell(100)

func sell(desired_num):
	var per_each_price = station_hold.sell_to_me_price(commodity_name)
	
	var sell_qty = desired_num
	
	#validations
	#first check if there's enough in our hold to sell
	var available_qty = ship_hold.get_amt(commodity_name)
	if sell_qty > available_qty:
		sell_qty = available_qty
		
	#now do it
	var total_price = per_each_price * sell_qty
	
	player_acct.add(total_price)
	station_hold.add(commodity_name, sell_qty)
	ship_hold.add(commodity_name, -sell_qty)
	print("sold ", sell_qty, " of ", commodity_name, " for ", total_price)
	#update the UI
	update()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
