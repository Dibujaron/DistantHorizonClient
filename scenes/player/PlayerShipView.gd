extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var zoom_factor = 0.5
var start_position
export var initial_velocity = Vector2(-300, 0)
var ship
# Called when the node enters the scene tree for the first time.
func _ready():
	start_position = global_position
	ship = get_parent()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_in()
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_out()
			
			

func _process(delta):
	if Input.is_action_just_pressed("ui_zoom_in"):
		zoom_in()
	if Input.is_action_just_pressed("ui_zoom_out"):
		zoom_out()
	if Input.is_action_pressed("ui_reset"):
		ship.global_position = start_position
		ship.velocity = initial_velocity
		ship.main_engines_active = false
	if not ship.docked:
		if Input.is_action_pressed("ui_rotate_right"):
			ship.rotating_right = true
		else:
			ship.rotating_right = false
		if Input.is_action_pressed("ui_rotate_left"):
			ship.rotating_left = true
		else:
			ship.rotating_left = false
	if Input.is_action_pressed("ui_fire_engines"):
		ship.enable_engines()
	else:
		ship.disable_engines()
	if Input.is_action_pressed("ui_strafe_left"):
		ship.enable_starboard_thrusters()
	else:
		ship.disable_starboard_thrusters()
	if Input.is_action_pressed("ui_strafe_right"):
		ship.enable_port_thrusters()
	else:
		ship.disable_port_thrusters()
	if Input.is_action_pressed("ui_strafe_forward"):
		ship.enable_aft_thrusters()
	else:
		ship.disable_aft_thrusters()
	if Input.is_action_pressed("ui_strafe_backward"):
		ship.enable_fore_thrusters()
	else:
		ship.disable_fore_thrusters()
		
	if Input.is_action_just_pressed("ui_dock"):
		if ship.docked:
			ship.undock()
		else:
			ship.attempt_dock()
	
func zoom_in():
	var camera = $Camera2D
	if camera.zoom.x > 0.5:
		camera.zoom = camera.zoom * zoom_factor	
		var new_zoom = camera.zoom.x
		var parallax_bg = get_tree().get_root().get_node("Space").get_node("ParallaxBackground")
		#parallax_bg.get_node("LayerTop").motion_scale *= zoom_factor
		#parallax_bg.get_node("LayerMiddle").motion_scale *= zoom_factor
		#parallax_bg.get_node("LayerLower").motion_scale *= zoom_factor
		if new_zoom <= 2:
			parallax_bg.get_node("LayerTop").show()
		if new_zoom <= 4:
			parallax_bg.get_node("LayerMiddle").show()
		if new_zoom <= 8:
			parallax_bg.get_node("LayerLower").show()
		print("camera zoom is ", camera.zoom)

func zoom_out():
	var camera = $Camera2D
	if camera.zoom.x < 64:
		camera.zoom = camera.zoom / zoom_factor
		var parallax_bg = get_tree().get_root().get_node("Space").get_node("ParallaxBackground")
		#parallax_bg.get_node("LayerTop").motion_scale /= zoom_factor
		#parallax_bg.get_node("LayerMiddle").motion_scale /= zoom_factor
		#parallax_bg.get_node("LayerLower").motion_scale /= zoom_factor
		var new_zoom = camera.zoom.x
		if new_zoom > 2:
			parallax_bg.get_node("LayerTop").hide()
		if new_zoom > 4:
			parallax_bg.get_node("LayerMiddle").hide()
		if new_zoom > 8:
			parallax_bg.get_node("LayerLower").hide()
		print("camera zoom is ", camera.zoom)
