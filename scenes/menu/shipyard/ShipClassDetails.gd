extends Control

var qualified_name = ""
var colors = []
var color_index = 0
func _ready():
	$DisplayContainer/PreviousColor.connect("pressed", self, "_previous_color")
	$DisplayContainer/NextColor.connect("pressed", self, "_next_color")
	$VBoxContainer/BuyButton.connect("pressed", self, "_buy_ship")
func init(ship_class_info):
	var identifying_name = ship_class_info["identifying_name"]
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
	Global.get_socket_client().buy_ship(qualified_name, colors[color_index][0], colors[color_index][1])
	
