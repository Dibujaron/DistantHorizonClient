extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pressed", self, "_pressed") # Replace with function body. # Replace with function body. # Replace with function body.

func _pressed():
	print("pressed browser button")
	OS.shell_open("https://www.w3schools.com")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
