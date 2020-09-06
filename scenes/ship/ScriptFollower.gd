extends Node

var steps = []
var final_step = 0 #this gets updated but really shouldn't.
var current_step_index = 0
func accept_steps(heartbeat_json):
	final_step = heartbeat_json["final_step"]
	var current_step_server = heartbeat_json["current_step"]
	var diff = current_step_server - current_step_index
	print("step is off by ", diff)
	
	#for now just skip to where we're supposed to be. We can interp better later.
	steps = heartbeat_json["future_steps"]
	current_step_index = current_step_server
	
var last_step_returned = null
func pop_next_step():
	#todo sometimes skip steps based on the variation in tick rate, or interpolate.
	var steps_remaining = final_step - current_step_index
	if steps_remaining > 0:
		if steps.empty():
			print("AI script ran out of steps in queue but has ", steps_remaining, " steps remaining??")
			return null
		else:
			var step = steps.pop_front()
			last_step_returned = step
			return step
	else:
		return last_step_returned #just hover if we have no more steps, dock message will arrive momentarily.
