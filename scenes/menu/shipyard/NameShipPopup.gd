extends PopupPanel

var ship_to_purchase_qualified_name
var ship_to_purchase_primary_color
var ship_to_purchase_secondary_color
var ship_names

func _ready():
	$VBoxContainer/BuyShipButton.connect("pressed", self, "_buy_ship")
	var file_contents = Global.load_text_file("res://ship_names.txt")
	ship_names = file_contents.split("\n")
	print("loaded " + str(ship_names.size()) + " ship names.")
	var ship_name = ship_names[randi() % ship_names.size()]
	$VBoxContainer/HBoxContainer/LineEdit.text = ship_name

func _buy_ship():
	var ship_name = $VBoxContainer/HBoxContainer/LineEdit.text
	Global.get_socket_client().buy_ship(ship_to_purchase_qualified_name, ship_name, ship_to_purchase_primary_color, ship_to_purchase_secondary_color)
	hide()
