extends AnimatedSprite

func _process(delta):
	var linked_ship = get_parent().get_linked_ship()
	if linked_ship:
		$Needle.global_rotation = linked_ship.global_rotation
