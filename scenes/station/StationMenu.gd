extends MarginContainer

var station_display_name
var station_desc
var menu_mode = "TRADE"
var vbox

func _ready():
	vbox = get_node("HBoxContainer/VBoxContainer")
	var depart_button = vbox.get_node("DepartButton")
	depart_button.connect("pressed", self, "_depart_pressed") # Replace with function body. # Replace with function body.
	depart_button.hint_tooltip = "hotkey: [Esc]"
	
func _depart_pressed():
	var client = get_tree().get_root().get_node("Space").get_node("WebSocketClient")
	client.undock()
	
func init(json):
	var station_info = json["station_info"]
	self.station_display_name = station_info["display_name"]
	self.station_desc = station_info["description"]
	vbox.get_node("HeaderLabel/StationName").text = station_display_name
	vbox.get_node("DescLabel/StationDesc").text = station_desc
	var content_holder = vbox.get_node("ContentHolder")
	for child in content_holder.get_children():
		content_holder.remove_child(child)
	if menu_mode == "TRADE":
		var tradeMenuScene = preload("res://scenes/station/trade/TradeMenu.tscn")
		var inst = tradeMenuScene.instance()
		content_holder.add_child(inst)
		inst.init(json)
	else:
		pass
