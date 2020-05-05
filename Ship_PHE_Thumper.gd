extends "res://Ship.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
var hold_occupied = 0
func _ready():
	
	main_engines = [get_node("EngineP"), get_node("EngineS")]
	port_thrusters = [get_node("ManuPF"), get_node("ManuPA")]
	starboard_thrusters = [get_node("ManuSF"), get_node("ManuSA")]
	fore_thrusters = [get_node("ManuFP"), get_node("ManuFS")]
	aft_thrusters = [get_node("ManuAP"), get_node("ManuAS")]
	docking_ports = [get_node("DockPortP"), get_node("DockPortS")]
	
func _process(delta):
	var hold_occupied_new = $CargoHold.occupied_space()
	if hold_occupied_new != hold_occupied:
		hold_occupied = hold_occupied_new
		update_containers()
		
func update_containers():
	var hold_occupied = $CargoHold.occupied_space()
	var hold_size = $CargoHold.size
	var occupancy = hold_occupied / (hold_size * 1.0)
	
	var containers = []
	for child in get_children():
		if child.is_in_group("CargoContainers"):
			containers.append(child)
	
	var containers_occupied = ceil(containers.size() * occupancy)
	for i in range(0, containers.size()):
		var container = containers[i]
		if i < containers_occupied:
			container.enable()
		else:
			container.disable()


	
