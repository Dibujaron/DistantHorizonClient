extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(commodity_info):
	var commodity_label = get_node("ImgContainer/Commodity")
	commodity_label.text = commodity_info["display_name"]	
	var commodity_price = get_node("Price")
	var price_val = commodity_info["price"]
	commodity_price.text = "$" + str(price_val)
	var path = "res://sprites/items/" + commodity_info["identifying_name"] + ".png"
	get_node("ImgContainer/ItemImg").texture = load(path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
