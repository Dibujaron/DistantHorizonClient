extends Node2D

export (NodePath) var socket_client_path
onready var socket_client = get_node(socket_client_path)
export var zoom_factor = 0.5
# Called when the node enters the scene tree for the first time.
var main_engines_pressed = false
var port_thrusters_pressed = false
var stbd_thrusters_pressed = false
var fore_thrusters_pressed = false
var aft_thrusters_pressed = false
var rotate_left_pressed = false
var rotate_right_pressed = false

func _ready():
	Global.set_primary_player(self)
	
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_in()
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_out()

func _process(_delta):
	
	if not Global.get_chat_hud().is_chat_focused():
		var updated = false
		if Input.is_action_just_pressed("ui_zoom_in"):
			zoom_in()
		if Input.is_action_just_pressed("ui_zoom_out"):
			zoom_out()
		if Input.is_action_just_pressed("ui_rotate_right"):
			updated=true
			rotate_right_pressed=true
		if Input.is_action_just_released("ui_rotate_right"):
			updated=true
			rotate_right_pressed=false
			
		if Input.is_action_just_pressed("ui_rotate_left"):
			updated=true
			rotate_left_pressed=true
		if Input.is_action_just_released("ui_rotate_left"):
			updated=true
			rotate_left_pressed=false
			
		if Input.is_action_just_pressed("ui_fire_engines"):
			updated=true
			main_engines_pressed=true
		if Input.is_action_just_released("ui_fire_engines"):
			updated=true
			main_engines_pressed=false
			
		if Input.is_action_just_pressed("ui_strafe_left"):
			updated=true
			stbd_thrusters_pressed=true
		if Input.is_action_just_released("ui_strafe_left"):
			updated=true
			stbd_thrusters_pressed=false
	
		if Input.is_action_just_pressed("ui_strafe_right"):
			updated=true
			port_thrusters_pressed=true
		if Input.is_action_just_released("ui_strafe_right"):
			updated=true
			port_thrusters_pressed=false
			
		if Input.is_action_just_pressed("ui_strafe_forward"):
			updated=true
			aft_thrusters_pressed=true
		if Input.is_action_just_released("ui_strafe_forward"):
			updated=true
			aft_thrusters_pressed=false
			
		if Input.is_action_just_pressed("ui_strafe_backward"):
			updated=true
			fore_thrusters_pressed=true
			
		if Input.is_action_just_released("ui_strafe_backward"):
			updated=true
			fore_thrusters_pressed=false
			
		if updated:
			var dict = {}
			dict["message_type"] = "ship_inputs"
			dict["main_engines_pressed"] = main_engines_pressed
			dict["port_thrusters_pressed"] = port_thrusters_pressed
			dict["stbd_thrusters_pressed"] = stbd_thrusters_pressed
			dict["fore_thrusters_pressed"] = fore_thrusters_pressed
			dict["aft_thrusters_pressed"] = aft_thrusters_pressed
			dict["rotate_left_pressed"] = rotate_left_pressed
			dict["rotate_right_pressed"] = rotate_right_pressed
			socket_client.queue_outgoing_message(dict)
			
		if Input.is_action_just_pressed("ui_dock"):
			print("attempting dock.")
			var dict = {}
			dict["message_type"] = "dock"
			socket_client.queue_outgoing_message(dict)
		if Input.is_action_just_pressed("ui_undock"):
			socket_client.undock()
			
		if Input.is_action_just_pressed("ui_focus_chat"):
			Global.get_chat_hud().focus_chat("")
		
		if Input.is_action_just_pressed("ui_chat_command"):
			Global.get_chat_hud().focus_chat("/")
			
		if Input.is_action_just_pressed("ui_navigation_menu"):
			Global.get_navigation_menu().toggle()
			
		if Input.is_action_just_pressed("ui_toggle_breadcrumbs"):
			print("got toggle crumbs")
			Global.get_primary_player_ship().toggle_breadcrumbs()
	else:
		if Input.is_action_just_pressed("ui_send_chat"):
			Global.get_chat_hud().send_chat_message()
		
		if Input.is_action_just_pressed("ui_cancel_chat"):
			Global.get_chat_hud().cancel_message()
	
func zoom_in():
	var camera = $Camera2D
	if camera.zoom.x > 0.25:
		camera.zoom = camera.zoom * zoom_factor	
		var new_zoom = camera.zoom.x
		var parallax_bg = get_tree().get_root().get_node("Space").get_node("ParallaxBackground")
		#parallax_bg.get_node("LayerTop").motion_scale *= zoom_factor
		#parallax_bg.get_node("LayerMiddle").motion_scale *= zoom_factor
		#parallax_bg.get_node("LayerLower").motion_scale *= zoom_factor
		if new_zoom <= 4:
			parallax_bg.get_node("LayerTop").show()
		if new_zoom <= 16:
			parallax_bg.get_node("LayerMiddle").show()
		#if new_zoom <= 8:
		#	parallax_bg.get_node("LayerLower").show()
		print("camera zoom is ", camera.zoom.x)

func zoom_out():
	var camera = $Camera2D
	if camera.zoom.x < 32:
		camera.zoom = camera.zoom / zoom_factor
		var parallax_bg = get_tree().get_root().get_node("Space").get_node("ParallaxBackground")
		#parallax_bg.get_node("LayerTop").motion_scale /= zoom_factor
		#parallax_bg.get_node("LayerMiddle").motion_scale /= zoom_factor
		#parallax_bg.get_node("LayerLower").motion_scale /= zoom_factor
		var new_zoom = camera.zoom.x
		if new_zoom > 4:
			parallax_bg.get_node("LayerTop").hide()
		if new_zoom > 16:
			parallax_bg.get_node("LayerMiddle").hide()
		#if new_zoom > 8:
		#	parallax_bg.get_node("LayerLower").hide()
		print("camera zoom is ", camera.zoom.x)
