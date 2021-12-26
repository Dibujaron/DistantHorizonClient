extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var docked_to
var is_docked
var grand_parent
export var max_closing_speed = 500 
var max_closing_speed_squared
export var port_name = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("DockingPortsMale")
	max_closing_speed_squared = max_closing_speed * max_closing_speed
func get_port_name():
	return port_name
	
func dock(dock_threshold):
	if not is_docked:
		var female = find_port_to_dock(dock_threshold)
		var closing_speed_squared = closing_speed_squared(female)
		if closing_speed_squared < max_closing_speed_squared:
			dock_to(female)
			print("port ", get_port_name(), " docked to ", female.get_port_name())
			print("closing speed ", sqrt(closing_speed_squared))
			return true
		else:
			print("closing speed ", sqrt(closing_speed_squared), " is too high, must be less than ", sqrt(max_closing_speed_squared))
			return false
		
func dock_to(target_port):
	if not is_docked:
		docked_to = target_port
		is_docked = true
		var parent = get_parent()
	
		grand_parent = parent.get_parent()
		
		grand_parent.remove_child(parent)
		docked_to.add_child(parent)
		var rotation_of_my_port = rotation
		var target_rotation = rotation_of_my_port
		parent.rotation = target_rotation
		parent.position = Vector2(position.x * -1, position.y)
		target_port.on_dock(parent)
		
func undock():
	if is_docked:
		is_docked = false
		var parent = get_parent()
		parent.set_velocity(docked_to.get_parent().global_velocity())
		var parent_pos = parent.global_position
		var parent_rot = parent.global_rotation
		docked_to.remove_child(parent)
		parent.global_position = parent_pos
		parent.global_rotation = parent_rot
		grand_parent.add_child(parent) #grandparent is space
		parent.global_position = parent_pos
		parent.global_rotation = parent_rot
		docked_to.on_undock()
		docked_to = null
# Called every frame. 'delta' is the elapsed time since the previous frame.

func find_port_to_dock(dock_threshold):
	var all_ports = get_tree().get_nodes_in_group("DockingPortsFemale")
	var dock_threshold_squared = dock_threshold * dock_threshold
	var best_matched_port
	var best_dist_squared = dock_threshold_squared #it'll never be more than this
	for port in all_ports:
		var other_position = port.global_position
		var my_position = global_position
		var dist_squared = (my_position - other_position).length_squared()
		if dist_squared < best_dist_squared:
			best_dist_squared = dist_squared
			best_matched_port = port
	return best_matched_port
	
func closing_speed_squared(target_port):
	return (get_parent().get_velocity() - target_port.get_parent().global_velocity()).length_squared()
	
func get_best_dock_dist(dock_threshold):
	var all_ports = get_tree().get_nodes_in_group("DockingPortsFemale")
	var dock_threshold_squared = dock_threshold * dock_threshold
	var best_dist_squared = dock_threshold_squared #it'll never be more than this
	for port in all_ports:
		var other_position = port.global_position
		var my_position = global_position
		var dist_squared = (my_position - other_position).length_squared()
		if dist_squared < best_dist_squared:
			best_dist_squared = dist_squared
	return best_dist_squared
