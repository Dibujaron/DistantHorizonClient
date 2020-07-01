extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(ship_class_info, color1, color2):
	var identifying_name = ship_class_info["identifying_name"]
	var manufacturer = ship_class_info["manufacturer"]
	var display_name = ship_class_info["display_name"]
	var main_thrust = ship_class_info["main_thrust"]
	var manu_thrust = ship_class_info["manu_thrust"]
	var hold_size = ship_class_info["hold_size"]
	var ship_display = preload("res://scenes/station/shipyard/ShipDisplay.tscn")
	var type_identifier = manufacturer + "." + identifying_name
	ship_display.instance()
	add_child(ship_display)
	ship_display.init(type_identifier, color1, color2)
	$VBoxContainer/Make.set_field_value(manufacturer)
	$VBoxContainer/Model.set_field_value(display_name)
	$VBoxContainer/MainThrust.set_field_value(main_thrust)
	$VBoxContainer/ManuThrust.set_field_value(manu_thrust)
	$VBoxContainer/HoldSize.set_field_value(hold_size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
