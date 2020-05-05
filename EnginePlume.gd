extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
var enabled = false;
export var anim_name = "small"

func _ready():
	$AnimatedSprite.play("empty")
	pass
	
func set_enabled(val):
	if not enabled && val:
		enabled = true
		$AnimatedSprite.play(anim_name)
	if enabled && not val:
		enabled = false
		$AnimatedSprite.play("empty")		
