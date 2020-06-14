extends "res://Ship.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
func _ready():
	main_engines = [get_node("Engine")]
	port_thrusters = []
	starboard_thrusters = []
	fore_thrusters = []
	aft_thrusters = []
	docking_ports = []
