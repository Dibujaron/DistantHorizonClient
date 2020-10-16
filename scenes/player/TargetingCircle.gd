extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var rotation_degrees_per_second = -20
export var scale_factor_base_close = 0.1
export var scale_factor_base_far = 0.05
var current_zoom = 0
var prior_global_rotation_degs = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.set_targeting_circle(self)

func is_circle_visible():
	return $TargetingVisibilityNotifier.is_on_screen()
	
func _process(delta):
	var rotation_amt = rotation_degrees_per_second * delta
	var new_rotation = prior_global_rotation_degs + rotation_amt
	$AnimatedSprite.global_rotation_degrees = new_rotation
	prior_global_rotation_degs = new_rotation
	var new_zoom = Global.get_current_zoom()
	if new_zoom != current_zoom:
		print("zoom factor is ", new_zoom)
		var new_scale_factor = scale_factor_base_close
		if new_zoom >= 32:
			new_scale_factor = scale_factor_base_far
		new_scale_factor = new_scale_factor * new_zoom
		scale.x = new_scale_factor
		scale.y = new_scale_factor
		current_zoom = new_zoom
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
