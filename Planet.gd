extends "res://Orbiter.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rotation_speed = 0
var tidal_lock = false
var type = "Star"

export var type_scale_map = {
	"Star": 1.0,
	"Continental": 0.2,
	"Moon": 0.1,
	"Gas": 0.75
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func json_init(planet_info):
	.json_init(planet_info)
	rotation_speed = planet_info["rotation_speed"]
	tidal_lock = planet_info["tidal_lock"]
	var new_type = planet_info["type"]
	if new_type != type:
		type = new_type
		$AnimatedSprite.play(type)
	scale.x = planet_info["scale"] * type_scale_map[type]
	scale.y = planet_info["scale"] * type_scale_map[type]

func json_update(planet_info):
	.json_update(planet_info)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if tidal_lock:
		$AnimatedSprite.look_at(get_parent().global_position)
	else:
		$AnimatedSprite.rotation += rotation_speed * delta

func json_to_vec(json):
	return Vector2(json["x"],json["y"])
