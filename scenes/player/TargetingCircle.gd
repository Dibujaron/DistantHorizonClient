extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var rotation_degrees_per_second = -20
export var scale_factor_base_close = 0.1
export var scale_factor_base_far = 0.05
var current_zoom = 0
var prior_global_rotation_degs = 0
var current_target = null
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	Global.set_targeting_circle(self)

func is_on_screen():
	return $TargetingVisibilityNotifier.is_on_screen()
	
func navigate_to(stn_name):
	var stn = Global.get_space().stations[stn_name]
	if stn != null:
		current_target = stn_name
		var parent = get_parent()
		if parent != null:
			parent.remove_child(self)
		stn.add_child(self)
		show()
	else:
		print("invalid station for navigation", stn_name)
	
func get_nav_target():
	return current_target
	
func stop_navigating():
	hide()
	
func is_enabled():
	return visible
	
func _process(delta):
	var rotation_amt = rotation_degrees_per_second * delta
	var new_rotation = prior_global_rotation_degs + rotation_amt
	$AnimatedSprite.global_rotation_degrees = new_rotation
	prior_global_rotation_degs = new_rotation
	var new_zoom = Global.get_current_zoom()
	if new_zoom != current_zoom:
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
