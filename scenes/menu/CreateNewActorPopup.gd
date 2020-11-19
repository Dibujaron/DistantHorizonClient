extends Popup


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var create_button = get_node("MainBox/CreateButton")
	create_button.connect("pressed", self, "_create_pressed")
	var cancel_button = get_node("MainBox/CancelButton")
	cancel_button.connect("pressed", self, "_cancel_pressed")
	
func _create_pressed():
	var nameEntry = $MainBox/NameEntryBox/NameEntry
	get_parent().create_actor(nameEntry.text)
	nameEntry.text = ""
	hide()
	
func _cancel_pressed():
	$MainBox/NameEntryBox/NameEntry.text = ""
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
