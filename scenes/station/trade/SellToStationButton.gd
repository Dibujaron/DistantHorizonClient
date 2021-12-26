extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var commodity_identifying_name
# Called when the node enters the scene tree for the first time.
func _ready():
	var _connect_result = connect("pressed", self, "_sell_pressed") # Replace with function body.
	hint_tooltip = "hold shift to sell 10, hold ctrl and shift to sell 100"
	
func init(commodity_identifying_name_input):
	self.commodity_identifying_name = commodity_identifying_name_input
	
func _sell_pressed():
	if(Input.is_action_pressed("ui_modifier_shift")):
		if(Input.is_action_pressed("ui_modifier_ctrl")):
			sell(100)
		else:
			sell(10)
	else:
		sell(1)
	
func sell(desired_num):
	var client = get_tree().get_root().get_node("Space").get_node("WebSocketClient")
	client.sell_to_station(commodity_identifying_name, desired_num)
	update()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
