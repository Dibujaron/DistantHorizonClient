extends Node2D
class_name PID_Controller

var _prev_error: float = 0.0
var _integral: float = 0.0
var _int_max = 200
export var _Kp: float = 0.01
export var _Ki: float = 2
export var _Kd: float = 0

func _ready():
	pass

func calculate(error, dt):
	var Pout = _Kp * error
	
	_integral += error * dt
	var Iout = _Ki * _integral
	
	var derivative = (error - _prev_error) / dt
	var Dout = _Kd * derivative
	
	var output = Pout + Iout + Dout
	
	if _integral > _int_max:
		_integral = _int_max
	elif _integral < -_int_max:
		_integral = -_int_max
	_prev_error = error
	return output

func reset_integral():
	_integral = 0.0
