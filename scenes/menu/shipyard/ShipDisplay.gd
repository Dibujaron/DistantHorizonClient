extends Control

export var rotation_speed_degrees_per_second = 10
var rotation_speed_rads_per_second = deg2rad(rotation_speed_degrees_per_second)
var engines_toggle_every_seconds = 1
var cargo_updates_every_seconds = 3

func init(ship_type_identifier, color1, color2):
	for child in get_children():
		remove_child(child)
	var ship_scene = Global.ship_scenes[ship_type_identifier]
	var displayed_ship = ship_scene.instance()
	displayed_ship.rotation = deg2rad(-90)
	displayed_ship.position = self.rect_size / 2
	displayed_ship.scale = Vector2(2,2)
	displayed_ship.static_display = true
	displayed_ship.hold_size = 100
	displayed_ship.initial_primary_color = color1
	displayed_ship.initial_secondary_color = color2
	add_child(displayed_ship)
	
func update_colors(color1, color2):
	for child in get_children():
		child._set_primary_color(color1)
		child._set_secondary_color(color2)
	
var engine_accumulator = 0
var engines_active = false

var cargo_accumulator = 0
var cargo_active = false
func _process(delta):
	var rotation_amount = rotation_speed_rads_per_second * delta
	if engine_accumulator > engines_toggle_every_seconds:
		engine_accumulator = 0
		engines_active = !engines_active
		for child in get_children():
			for engine in child.main_engines:
				engine.set_enabled(engines_active)
	if cargo_accumulator > cargo_updates_every_seconds:
		cargo_active = !cargo_active
		for child in get_children():
			if cargo_active:
				var cargo_amount = min(child.hold_size, randf() * child.hold_size * 2)
				child.hold_occupied = int(cargo_amount)
			else:
				child.hold_occupied = 0
		cargo_accumulator = 0
	for child in get_children():
		child.rotation = child.rotation + rotation_amount
	engine_accumulator += delta
	cargo_accumulator += delta
