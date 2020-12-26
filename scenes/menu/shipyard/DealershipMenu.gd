extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var manu_identifying_name = ""
var manu_display_name_long = ""
var manu_display_name_short = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(dealership_json):
	manu_identifying_name = dealership_json["identifying_name"]
	manu_display_name_short = dealership_json["display_name_short"]
	manu_display_name_long = dealership_json["display_name_long"]
	set_name(manu_display_name_short)
	print("initializing dealership menu for ", manu_identifying_name)
	$LogoCenter/Logo.texture = load("res://sprites/companies/" + manu_identifying_name + ".png")
	$Description.text = dealership_json["description"]
	var ship_classes = dealership_json["ship_classes"]
	var ship_class_detail_scene = preload("res://scenes/menu/shipyard/ShipClassDetails.tscn")
	for ship_class in ship_classes:
		var details_inst = ship_class_detail_scene.instance()
		details_inst.init(ship_class)
		$ShipClassBox.add_child(details_inst)
