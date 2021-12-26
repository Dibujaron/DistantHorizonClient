extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var _connect_result = connect("pressed", self, "_navigate_pressed") # Replace with function body. # Replace with function body.

func _navigate_pressed():
	print("navigate pressed.")
	get_parent().on_selected()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
