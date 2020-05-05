extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var port_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("DockingPortsFemale")

func get_port_name():
	return port_name
	
func on_dock(docked_ship):
	get_parent().on_dock(docked_ship)
	
func on_undock():
	get_parent().on_undock()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
