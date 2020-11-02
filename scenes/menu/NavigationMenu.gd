extends VBoxContainer

export var update_every_n_ticks = 60 * 5
export var left_pad_when_in_station = 100
var ticks_since_update = 0
var base_margin
# Called when the node enters the scene tree for the first time.
func _ready():
	base_margin = margin_left
	hide() # Replace with function body.

func init():
	var stations = Global.get_space().stations
	var menu_item_scene = preload("res://scenes/menu/NavigationMenuItem.tscn")
	for stn_name in stations.keys():
		var inst = menu_item_scene.instance()
		$VBoxContainer.add_child(inst)
		inst.init(self, stn_name)
	do_update()
		
func on_navigation_selected(stn_name):
	print("navigating to ", stn_name)
	Global.get_targeting_circle().navigate_to(stn_name)
	hide()
	
func toggle():
	visible = !visible
	
func _process(delta):
	var margin = base_margin
	var station_menu = Global.get_station_menu()
	if station_menu != null:
		margin += station_menu.rect_size.x + left_pad_when_in_station
	margin_left = margin
	
	if ticks_since_update >= update_every_n_ticks:
		update()
		ticks_since_update = 0
	ticks_since_update += 1
	
func do_update():
	var children = $VBoxContainer.get_children()
	var children_sorted = children.duplicate()
	children_sorted.sort_custom(self, "sort_by_distance")
	var num_children = children.size()
	for i in range(0, num_children):
		var child = children_sorted[i]
		$VBoxContainer.move_child(child, i)
					
	for child in $VBoxContainer.get_children():
		child.do_update()

func sort_by_distance(a,b):
	var dist_a = a.get_dist_squared()
	var dist_b = b.get_dist_squared()
	return dist_a < dist_b
