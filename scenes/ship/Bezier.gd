extends Object

var startPos: Vector2
var startVel: Vector2
var endPos: Vector2
var endVel: Vector2
var length
var duration
var resolution = 100
var mainThrust
var distToFlip
var timeToFlip
func setup(startPos: Vector2, startVel: Vector2, endPos: Vector2, endVel: Vector2, mainEngineThrust):
	self.startPos = startPos
	self.startVel = startVel
	self.endPos = endPos
	self.endVel = endVel
	self.mainThrust = mainEngineThrust
	self.length = compute_length()
	self.distToFlip = ((mainThrust * self.length) + (endVel.length() - startVel.length())) / (mainThrust * 2)
	self.timeToFlip = travel_time(self.startVel.length(), self.mainThrust, distToFlip)
	var decelDist = self.length - distToFlip
	var decelTime = travel_time(self.endVel.length(), self.mainThrust, decelDist)
	self.duration = self.timeToFlip + decelTime

var timeOffsetFromStart = 0.0
func has_next_step(delta):
	return previousDistance < self.length

func step(delta, priorPosition):
	var newTime = timeOffsetFromStart + delta
	var state = state_at_time(newTime, delta, priorPosition)
	timeOffsetFromStart = newTime
	return state

var previousDistance = 0
func state_at_time(time, delta, priorPosition):
	var startSpeed = startVel.length()
	var maxAccel = self.mainThrust
	var accelTime = time if time < self.timeToFlip else timeToFlip
	var decelTime = time - timeToFlip if time > timeToFlip else 0.0
	var accelDist = startSpeed * accelTime + 0.5 * maxAccel * accelTime * accelTime
	var speedAtFlip = sqrt(startSpeed * startSpeed + 2 * maxAccel * accelDist)
	var decelDist = speedAtFlip * decelTime + 0.5 * -maxAccel * decelTime * decelTime
	var totalDist = accelDist + decelDist
	var t = t_for_distance(totalDist)
	var newPosition = get_coordinates_at(t)
	var newVelocity = (newPosition - priorPosition) * delta
	var gravity = Global.get_gravity_acceleration(newPosition)
	var gravityCounter = gravity * - 1.0
	var tangent = newVelocity.normalized()
	var accelVec = tangent * maxAccel
	var requiredAccel = accelVec if time < timeToFlip else accelVec * -1.0
	var totalThrust = requiredAccel + gravityCounter
	var newRotation = totalThrust.angle() + deg2rad(90)
	previousDistance = totalDist
	return [newPosition, newRotation, newVelocity, totalThrust]
	
var coordinate_length_cache = []
func compute_length():
	var fraction = 1.0 / self.resolution
	var length = 0.0
	var last_coordinates = self.startPos
	coordinate_length_cache.append([last_coordinates, 0.0])
	for i in range(0, resolution):
		var coords = get_coordinates_at(fraction * i)
		var dist = (coords - last_coordinates).length()
		length += dist
		coordinate_length_cache.append([coords, length])
		last_coordinates = coords
	return length

func distance_for_t(t):
	var lower = int(t * self.resolution)
	var cached = coordinate_length_cache[lower]
	var closest_cached_pos = cached[0] #position
	var closest_cached_dist = cached[1] #distance
	var pos_for_t = get_coordinates_at(t)
	var dist_from_closest = (pos_for_t - closest_cached_pos).length()
	return closest_cached_dist + dist_from_closest
	
func t_for_distance(distance_from_start):
	var lower_limit = 0.0
	var upper_limit = 1.0

	var prior_m = 0.0
	while lower_limit < upper_limit:
		var m = (lower_limit + upper_limit) / 2.0
		if m == prior_m:
			return m
		var dist_for_m = distance_for_t(m)
		if dist_for_m < distance_from_start:
			lower_limit = m
		elif dist_for_m > distance_from_start:
			upper_limit = m
		else:
			return m
		prior_m = m
	return lower_limit

func get_coordinates_at(t: float):
	return bezier_calc(startPos, startPos + (startVel * 10), endPos - (endVel * 10), endPos, t)
	
#copied from the docs
func bezier_calc(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var q2 = p2.linear_interpolate(p3, t)

	var r0 = q0.linear_interpolate(q1, t)
	var r1 = q1.linear_interpolate(q2, t)

	var s = r0.linear_interpolate(r1, t)
	return s

func travel_time(startSpeed, accel, distance):
	var a = accel
	var d = distance
	var v = startSpeed
	if a == 0.0:
		if v == 0.0:
			return INF
		else:
			return d / v
	else:
		var sqrtRes = sqrt((2 * a * d) + (v * v))
		var r1 = -1 * ((sqrtRes + v) / a)
		if r1 == NAN || r1 < 0:
			var r2 = (sqrtRes - v) / a
			return r2 #could be nan or negative but no way to throw here so just let it go
		else:
			return r1
				
