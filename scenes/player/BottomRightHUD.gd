extends VBoxContainer

var linked_ship = null
export var update_absolute_speed_every_n_ticks = 60

func _ready():
	pass
	
func link_ship(ship):
	linked_ship = ship
		
func get_linked_ship():
	return linked_ship

var ticks_since_update = 0
var distance_enabled = false
func _process(_delta):
	var targeting_circle = Global.get_targeting_circle()
	var should_distance_be_enabled = targeting_circle != null and targeting_circle.is_enabled()
	if distance_enabled != should_distance_be_enabled or ticks_since_update >= update_absolute_speed_every_n_ticks:
		do_update(targeting_circle)
		update_velocity()
		update_gas()
		distance_enabled = should_distance_be_enabled
		ticks_since_update = 0
	ticks_since_update += 1
	
func do_update(targeting_circle):
	var target_dist_label = $DistToTargetLabel
	if targeting_circle and targeting_circle.is_enabled() and get_linked_ship():
		var offset = targeting_circle.global_position - get_linked_ship().global_position
		var dist = offset.length()
		target_dist_label.text = "Distance to target: " + Global.pretty_print_distance(dist)
	else:
		target_dist_label.text = ""
		
func update_velocity():
	var ship = Global.get_primary_player_ship()
	if ship:
		var speed = ship.velocity.length()
		$VelocityLabel.text = "Absolute speed: " + Global.pretty_print_speed(speed)

func update_gas():
	var ship = Global.get_primary_player_ship()
	if ship:
		var fuel_level = ship.fuel_level
		var fuel_tank_size = ship.fuel_tank_size
		var fuel_fraction = fuel_level / fuel_tank_size
		var gas_percentage = fuel_fraction * 100
		$GasContainer/GaugeHolder/GasGauge.set_value(gas_percentage)
