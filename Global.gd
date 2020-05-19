extends Node

var chosenPrimaryColor: Color = Color.blue
var chosenSecondaryColor: Color = Color.white
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func angular_diff(a, b):
	var vecA = polar2cartesian(1, a)
	var vecB = polar2cartesian(1, b)
	return vecB.angle_to(vecA)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
