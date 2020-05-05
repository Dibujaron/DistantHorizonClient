extends Node2D


var enabled = false;
export var color = "red"

func _ready():
	add_to_group("CargoContainers")
	$AnimatedSprite.play("empty")
	pass
	
func enable():
	if not enabled:
		enabled = true
		$AnimatedSprite.play(color)
	
func disable():
	if enabled:
		enabled = false
		$AnimatedSprite.play("empty")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
