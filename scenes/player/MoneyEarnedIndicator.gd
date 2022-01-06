extends Node2D

export var spread = PI/2
export var travel = Vector2(0, -80)
export var duration = 2

#based on https://kidscancode.org/godot_recipes/ui/floating_text/
var position_offset = Vector2(0,0)
func _process(delta):
	global_rotation_degrees = 0.0
	global_position.x = get_parent().global_position.x + position_offset.x
	global_position.y = get_parent().global_position.y + position_offset.y

func show_value(value):
	$Label.text = "$" + str(value)
	var movement = travel.rotated(rand_range(-spread/2, spread/2))
	$Label.rect_pivot_offset = $Label.rect_size / 2
	$Tween.interpolate_property(self, "position_offset", 
		position_offset, position_offset + movement,
		duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Label, "modulate:a",
		1.0, 0.0, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()
