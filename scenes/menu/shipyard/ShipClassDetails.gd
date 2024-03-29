extends Control

var qualified_name = ""
var colors = []
var color_index = 0
var buy_ship_popup
func _ready():
	var _connect_result = $DisplayContainer/PreviousColor.connect("pressed", self, "_previous_color")
	var _connect_result2 = $DisplayContainer/NextColor.connect("pressed", self, "_next_color")
	var _connect_result3 = $VBoxContainer/BuyButton.connect("pressed", self, "_buy_ship")
func init(ship_class_info, buy_ship_popup_input):
	self.buy_ship_popup = buy_ship_popup_input
	qualified_name = ship_class_info["qualified_name"]
	colors = ship_class_info["colors"]
	var display_name = ship_class_info["display_name"]
	var main_thrust = ship_class_info["main_engine_thrust"]
	var hold_size = ship_class_info["hold_size"]
	var rotation_power = ship_class_info["rotation_power"]
	var price = ship_class_info["price"]
	var ship_display = $DisplayContainer/DisplayCenterer/ShipDisplay
	var primary_color = Global.json_to_color(colors[color_index][0])
	var secondary_color = Global.json_to_color(colors[color_index][1])
	ship_display.init(qualified_name, primary_color,secondary_color)
	$VBoxContainer/Model.set_field_value(display_name)
	$VBoxContainer/MainThrust.set_field_value(main_thrust)
	$VBoxContainer/HoldSize.set_field_value(hold_size)
	$VBoxContainer/RotationPower.set_field_value(rotation_power)
	$VBoxContainer/Price.set_field_value(price)
	$VBoxContainer/InStock.set_field_value(colors.size())
	
	if colors.size() < 2:
		$DisplayContainer/PreviousColor.hide()
		$DisplayContainer/NextColor.hide()
		
func _previous_color():
	if color_index == 0:
		color_index = colors.size() - 1
	else:
		color_index = color_index - 1
	print("color index is ", color_index, " out of ", colors.size())
	update_colors()
	
func _next_color():
	if color_index == (colors.size() - 1):
		color_index = 0
	else:
		color_index = color_index + 1
	print("color index is ", color_index, " out of ", colors.size())
	update_colors()
	
func update_colors():
	var ship_display = $DisplayContainer/DisplayCenterer/ShipDisplay
	var primary_color = Global.json_to_color(colors[color_index][0])
	var secondary_color = Global.json_to_color(colors[color_index][1])
	ship_display.update_colors(primary_color, secondary_color)
	
func _buy_ship():
	print("buying ship")
	buy_ship_popup.ship_to_purchase_qualified_name = qualified_name
	buy_ship_popup.ship_to_purchase_primary_color = colors[color_index][0]
	buy_ship_popup.ship_to_purchase_secondary_color = colors[color_index][1]
	buy_ship_popup.popup_centered()
	
