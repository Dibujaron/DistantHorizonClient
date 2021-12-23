extends Node2D

export var rotation_degrees_per_second = -20
export var scale_factor_base_close = 0.1
var current_zoom = 0
var prior_global_rotation_degs = 0

func _ready():
	hide()
	Global.set_poi_circle(self)

func is_on_screen():
	return $TargetingVisibilityNotifier.is_on_screen()
	
func select_object(target_object, poi_text):
	var parent = get_parent()
	if parent != null:
		parent.remove_child(self)
	target_object.add_child(self)
	$TextHolder/RichTextLabel.text = poi_text
	update_zoom(Global.get_current_zoom())
	
func stop_navigating():
	hide()
	
func is_enabled():
	return visible && get_parent() != null
	
func _process(delta):
	var parent = get_parent()
	if parent != null && parent.visible:
		show()
		$TextHolder.global_rotation_degrees = 0.0
		$TextHolder.global_position.x = global_position.x + (32 * current_zoom)
		$TextHolder.global_position.y = global_position.y
		var rotation_amt = rotation_degrees_per_second * delta
		var new_rotation = prior_global_rotation_degs + rotation_amt
		$AnimatedSprite.global_rotation_degrees = new_rotation
		prior_global_rotation_degs = new_rotation
		var new_zoom = Global.get_current_zoom()
		if new_zoom != current_zoom:
			update_zoom(new_zoom)
	else:
		hide()

func update_zoom(new_zoom):
	var new_scale_factor = scale_factor_base_close
	new_scale_factor = new_scale_factor * new_zoom
	global_scale.x = new_scale_factor
	global_scale.y = new_scale_factor
	current_zoom = new_zoom	
