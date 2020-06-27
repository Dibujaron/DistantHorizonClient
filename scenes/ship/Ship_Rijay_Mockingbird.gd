extends "res://scenes/ship/Ship.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
func _ready():
	
	main_engines = [get_node("EngineP"), get_node("EngineC"), get_node("EngineS")]
	port_thrusters = [get_node("ManuPF"), get_node("ManuPA")]
	starboard_thrusters = [get_node("ManuSF"), get_node("ManuSA")]
	fore_thrusters = [get_node("ManuFP"), get_node("ManuFS")]
	aft_thrusters = [get_node("ManuAP"), get_node("ManuAS")]
	docking_ports = []
