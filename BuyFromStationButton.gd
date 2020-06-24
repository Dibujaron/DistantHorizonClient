extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var commodity_identifying_name
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pressed", self, "_buy_pressed") # Replace with function body.
	hint_tooltip = "hold shift to buy 10, hold ctrl and shift to buy 100"
	
func init(commodity_identifying_name):
	self.commodity_identifying_name = commodity_identifying_name
	
func _buy_pressed():
	if(Input.is_action_pressed("ui_modifier_shift")):
		if(Input.is_action_pressed("ui_modifier_ctrl")):
			buy(100)
		else:
			buy(10)
	else:
		buy(1)
	
func buy(desired_num):
	var client = get_tree().get_root().get_node("Space").get_node("WebSocketClient")
	client.purchase_from_station(commodity_identifying_name, desired_num)
	update()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
