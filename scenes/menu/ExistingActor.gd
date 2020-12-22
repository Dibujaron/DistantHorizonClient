extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var display_name = ""
var unique_id = null
var welcome_screen_controller = null
# Called when the node enters the scene tree for the first time.
func _ready():
	var select_button = $TopBar/SelectButton
	var delete_button = $TopBar/DeleteButton
	select_button.connect("pressed", self, "_select_self")
	delete_button.connect("pressed", self, "_delete_self")
	
func json_init(welcome_screen, actorJson):
	welcome_screen_controller = welcome_screen
	display_name = actorJson["display_name"]
	unique_id = actorJson["unique_id"]
	$TopBar/CaptainLabel.set_field_value(display_name)
	$TopBar/BalanceLabel.set_field_value(str(actorJson["balance"]))
	if actorJson.has("station_display_name"):
		$TopBar/DockedAtLabel.set_field_value(actorJson["station_display_name"])
	else:
		$TopBar/DockedAtLabel.set_field_value("none")
	#var shipJson = actorJson["ship"]
	#var primary_color = Global.json_to_color(shipJson["primary_color"])
	#var secondary_color = Global.json_to_color(shipJson["secondary_color"])
	#$ShipDisplay.init(shipJson["ship_class"], primary_color, secondary_color)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _select_self():
	Global.actor_id = unique_id
	welcome_screen_controller._join_game()
	
func _delete_self():
	print("delete self called.")
	welcome_screen_controller.delete_actor(unique_id)
