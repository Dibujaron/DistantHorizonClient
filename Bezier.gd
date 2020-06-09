extends Object

var startPos: Vector2
var startVel: Vector2
var endPos: Vector2
var endVel: Vector2
var length
var duration
func setup(startPos: Vector2, startVel: Vector2, endPos: Vector2, endVel: Vector2):
	self.startPos = startPos
	self.startVel = startVel
	self.endPos = endPos
	self.endVel = endVel
	self.length = compute_length()
	self.duration = compute_duration()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current_offset = 0.0
func has_next_step(delta):
	var newT = t_for_time_offset(current_offset + delta)
	return newT <= 1.0

func step(delta):
	var newTime = current_offset + delta
	var newT = t_for_time_offset(newTime)
	var pos = get_coordinates_at(newT)
	var futureT = newT + t_for_time_offset(0.01)
	var futurePos = get_coordinates_at(futureT)
	var velocity = (futurePos - pos) * 100.0
	var pastT = newT + t_for_time_offset(-0.01)
	var pastPos = get_coordinates_at(pastT)
	var pastVelocity = (pos - pastPos) * 100.0
	var requiredAccelForFiftiethOfSecond = velocity - pastVelocity
	var requiredAccel = requiredAccelForFiftiethOfSecond * 50.0
	var gravity = Global.get_gravity_acceleration(pos)
	var gravityCounter = gravity * -1.0
	var totalThrust = requiredAccel + gravityCounter
	var rotation = totalThrust.angle() + deg2rad(90)
	current_offset = newTime
	return [pos, rotation, velocity]
	
func t_for_time_offset(timeOffset):
	return timeOffset / self.duration


func compute_duration():
	var a = abs(endVel.length() - startVel.length())
	var u = startVel.length()
	var s = self.length
	if a == 0:
		if u != 0:
			return s / u
		else:
			return INF
	else:
		var sqrt_res = sqrt((2 * a * s) + (u * u))
		var r1 = -1 * ((sqrt_res + u) / a)
		if r1 == NAN or r1 < 0:
			var r2 = (sqrt_res - u) / a
			if r2 == NAN or r2 < 0:
				print("error no valid result for duration")
			else:
				return r2
		else:
			return r1
	
func compute_length():
	var resolution = 100.0
	var fraction = 1.0 / resolution
	var length = 0.0
	var last_coordinates = self.startPos
	for i in range(0, resolution):
		var coords = get_coordinates_at(fraction * i)
		var dist = (coords - last_coordinates).length()
		length += dist
		last_coordinates = coords
	return length

func get_coordinates_at(t: float):
	return bezier_calc(startPos, startPos + startVel, endPos - endVel, endPos, t)
	
#copied from the docs
func bezier_calc(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var q2 = p2.linear_interpolate(p3, t)

	var r0 = q0.linear_interpolate(q1, t)
	var r1 = q1.linear_interpolate(q2, t)

	var s = r0.linear_interpolate(r1, t)
	return s
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
