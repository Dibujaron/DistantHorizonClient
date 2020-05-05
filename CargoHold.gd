extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var infinite_space = false
export var size = 500

export var commodities_map = {
	"hydrogen": 0,
	"food": 0,
	"iron_ore": 0,
	"copper_ore": 0,
	"water": 0,
	"luxuries": 0,
	"encrypted_data": 0,
	"machinery": 0,
	"munitions": 0,
	"biological_cells": 0,
	"energy_crystals": 0,
	"cryptonium": 0,
	"rush": 0
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func available_space():
	if infinite_space:
		return 10000000
	else:
		var retval = size
		for comm in commodities_map.keys():
			var amt = get_amt(comm)
			retval -= amt
		return retval
	
func occupied_space():
	return size - available_space()
func get_amt(commodity_name):
	return commodities_map[commodity_name]
	
func add(commodity_name, amt):
	if commodities_map.has(commodity_name):
		commodities_map[commodity_name] += amt
	else:
		commodities_map[commodity_name] = amt
		
func sell_to_me_price(commodity_name):
	return 1
	
func buy_from_me_price(commodity_name):
	return 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
