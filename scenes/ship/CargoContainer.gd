extends Node2D


var enabled = false;

export var colors = [Color.red, Color.orange, Color.yellow, Color.blue, Color.green, Color.purple, Color.gray, Color.brown]
func _ready():
	add_to_group("CargoContainers")
	$AnimatedSprite.play("empty")
	pass
	
func enable():
	if not enabled:
		enabled = true
		$AnimatedSprite.play("full")
		$AnimatedSprite.modulate = colors[randi() % colors.size()]
	
func disable():
	if enabled:
		enabled = false
		$AnimatedSprite.play("empty")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
