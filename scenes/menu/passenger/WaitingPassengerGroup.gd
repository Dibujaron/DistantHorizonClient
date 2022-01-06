extends PanelContainer

var selected = false
var destination = ""
var quantity = 0

var selected_style = preload("res://styleboxes/selectable_selected.tres")
var un_selected_style = preload("res://styleboxes/selectable_unselected.tres")
func _ready():
	set_selected(false)
	
func init(json):
	destination = json["destination_station"]
	quantity = json["quantity"]
	var destination_display_name = json["destination_station_display_name"] + " "
	$VBoxContainer/CenterContainer/DestinationField.set_field_value(destination_display_name)
	$VBoxContainer/CenterContainer2/QuantityField.set_field_value(quantity)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && get_global_rect().has_point(event.global_position):
			get_parent().get_parent().select_group(self)
			
func set_selected(selected):
	self.selected = selected
	if selected:
		set("custom_styles/panel", selected_style)
	else:
		set("custom_styles/panel", un_selected_style)
	update()
