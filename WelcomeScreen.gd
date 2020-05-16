extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	get_node("VBoxContainer/JoinButton").connect("pressed", self, "_join_game")

func _process(delta):
	var screen_size = get_viewport_rect().size
	var my_size = rect_size
	var screen_center = screen_size * 0.5
	var half_my_size = my_size * 0.5
	rect_position = screen_center - half_my_size
	pass # Replace with function body.

func _join_game():
	get_tree().change_scene("res://Space.tscn")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
