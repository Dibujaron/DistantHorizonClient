extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ship
var destination
var time_step
var max_accel
func _init(ship, destination, time_step, max_accel):
	self.ship = ship
	self.destination = destination
	self.time_step = time_step
	self.max_accel = max_accel
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	#https://godotengine.org/qa/12915/priority-queue

# modified A*
# based on https://www.geeksforgeeks.org/a-search-algorithm/
# this doesn't account for initial velocity or final velocity!
func calculate():
	var PriorityQueue = load("res://PriorityQueue.gd")
	var score_comparison_func = funcref(self, 'compare_state_scores')
	var equal_position_func = funcref(self, 'equal_positions')
	var open_list = PriorityQueue.new(score_comparison_func, equal_position_func)
	var closed_list = PriorityQueue.new(score_comparison_func, equal_position_func)
	
	var start_state = ShipState.new().init_from_ship(ship)
	start_state.time_steps = 0
	open_list.append(start_state)
	
	while not open_list.empty():
		var q = open_list.pop()
		var next_states = q.next_states(time_step, ship)
		for successor in next_states
		
func compare_state_scores(a, b):
	return f(a) - f(b)
	
func equal_positions(a, b):
	return a.roughly_equal_to(b)
	
func f(state):
	return g(state) + h(state)
	
func g(state):
	return state.time_steps * time_step
	
func h(state):
	if not state.has_cached_h:
		state.cached_h = best_travel_time(state.global_position, state.time_steps * time_step, max_accel, destination)
		state.has_cached_h = true
	return state.cached_h
	
# todo this doesn't account for initial velocity
func best_travel_time(start, current_time, max_accel, target_body):
	var travel_time = 0
	var iterations = 0
	var past_results_size = 5
	var past_results_list = []
	while iterations < 100000:
		var arrival_time = current_time + travel_time
		var end = target_body.global_position_at_time(arrival_time)
		travel_time = travel_time(start, end, arrival_time, max_accel)
		past_results_list.push_front(travel_time)
		if iterations >= past_results_size:	
			var diff = abs(average(past_results_list) - travel_time)
			if diff < 0.1:
				break
			past_results_list.pop_back()
		iterations += 1
	return travel_time
	
func average(arr):
	var sum = 0
	for elem in arr:
		sum += elem
	return sum / arr.size()
	
func travel_time(start, end, arrive_at_time, max_accel):
	var dist = (end-start).length()
	var accelerate_dist = dist / 2
	var time_accelerate = sqrt(accelerate_dist / (0.5 * max_accel))
	#with decel time, it's * 2
	return time_accelerate * 2
	
class ShipState:
	var time_steps
	var global_position
	var velocity
	var global_rotation
	var inputs
	var parent_state
	
	var has_cached_h = false
	var cached_h
	
	func roughly_equal_to(other_state):
		if time_steps != other_state.time_steps:
			return false
		var rotation_diff = abs(global_rotation - other_state.global_rotation)
		if rotation_diff > 0.0872: #5 degrees
			return false
		var position_diff_squared = (global_position - other_state.global_position).length_squared()
		if position_diff_squared > 100:
			return false
		var velocity_diff_squared = (velocity - other_state.velocity).length_squared()
		if velocity_diff_squared > 100:
			return false
		return true
		
	func copy_from(state):
		self.global_position = state.global_position
		self.velocity = state.velocity
		self.global_rotation = state.global_rotation
		self.inputs = ShipInputs.new().init_from(state.inputs)
		self.parent_state = state.parent_state
		
	func init_from_ship(ship):
		self.global_position = ship.global_position
		self.velocity = ship.velocity
		self.global_rotation = ship.global_rotation
		self.inputs = ShipInputs.new().init_from(ship)
		
	func next_states(delta, ship):
		#we can change one input per frame.
		
		var state_copy = ShipState.new().copy_from(self)
		var state_iterated = state_copy.iterate(delta, ship)
		state_iterated.parent_state = self
		var next_states = []
		next_states.resize(8)
		next_states[0] = state_iterated
		for i in range(1,8):
			next_states[i] = ShipState.new().copy_from(state_iterated)
		#next_states[0] is left unchanged.
		next_states[1].inputs.main_thrusters_active = !state_iterated.inputs.main_thrusters_active
		next_states[2].inputs.main_thrusters_active = !state_iterated.inputs.port_thrusters_active
		next_states[3].inputs.main_thrusters_active = !state_iterated.inputs.starboard_thrusters_active
		next_states[4].inputs.main_thrusters_active = !state_iterated.inputs.fore_thrusters_active
		next_states[5].inputs.main_thrusters_active = !state_iterated.inputs.aft_thrusters_active
		next_states[6].inputs.main_thrusters_active = !state_iterated.inputs.rotating_left
		next_states[7].inputs.main_thrusters_active = !state_iterated.inputs.rotating_right
		return next_states
		
	func iterate(delta, ship):
		self.global_position = global_position + velocity
		self.velocity = next_velocity(delta, ship)
		self.global_rotation = next_rotation(delta, ship)
		self.time_steps = time_steps + 1
		
	func next_velocity(delta, ship):
		var velocity = self.velocity
		if self.main_engines_active:
			velocity += Vector2(0,-ship.main_engine_thrust).rotated(self.rotation) * delta
		if self.starboard_thrusters_active:
			velocity += Vector2(-ship.manu_engine_thrust, 0).rotated(self.rotation) * delta
		if self.port_thrusters_active:
			velocity += Vector2(ship.manu_engine_thrust, 0).rotated(self.rotation) * delta
		if self.fore_thrusters_active:
			velocity += Vector2(0, ship.manu_engine_thrust).rotated(self.rotation) * delta
		if self.aft_thrusters_active:
			velocity += Vector2(0, -ship.manu_engine_thrust).rotated(self.rotation) * delta
		#todo move this method here or standardize
		self.velocity = velocity + ship.gravity_acceleration_at_time(0, self.global_position)
		return velocity
		
	func next_rotation(delta, ship):
		var rotation
		if self.rotating_left:
			rotation = self.rotation - (ship.rotation_power * delta) #todo multiply by delta
		if self.rotating_right:
			rotation = self.rotation + (ship.rotation_power * delta)
		return rotation

class ShipInputs:
	var global_rotation
	var main_engines_active
	var port_thrusters_active
	var starboard_thrusters_active
	var fore_thrusters_active
	var aft_thrusters_active
	var rotating_left
	var rotating_right
	
	func init_from(ship_or_inputs):
		main_engines_active = ship_or_inputs.main_engines_active
		port_thrusters_active = ship_or_inputs.port_thrusters_active
		starboard_thrusters_active = ship_or_inputs.starboard_thrusters_active
		fore_thrusters_active = ship_or_inputs.fore_thrusters_active
		aft_thrusters_active = ship_or_inputs.aft_thrusters_active
		rotating_left = ship_or_inputs.rotating_left
		rotating_right = ship_or_inputs.rotating_right
