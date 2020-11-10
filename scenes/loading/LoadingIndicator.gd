extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var moon_rotation_speed = -0.1
export var station_rotation_speed = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	$FakeMoon.rotation = $FakeMoon.rotation + moon_rotation_speed * delta
	$FakeStationAxis.rotation = $FakeStationAxis.rotation + station_rotation_speed
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
