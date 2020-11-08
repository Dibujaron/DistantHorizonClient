extends "res://scenes/ship/Ship.gd"

func _ready():
	
	main_engines = [get_node("EngineL"), get_node("EngineR")]
	port_thrusters = []
	starboard_thrusters = []
	fore_thrusters = []
	aft_thrusters = []
	docking_ports = []

func _get_center_mass():
	return Vector2(0, -5)
