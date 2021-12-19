extends VBoxContainer

func _ready():
	$FillTankButton.connect("pressed", self, "_fill_tank")
	$Fill100Button.connect("pressed", self, "_fill_100")

var fuel_level
var fuel_tank_size

func init(json):
	var player_balance = json["player_balance"]
	fuel_level = json["fuel_level"]
	print("initializing fuel menu, fuel level is " + str(fuel_level))
	fuel_tank_size = json["fuel_tank_size"]
	var station_info = json["station_info"]
	var fuel_price = station_info["fuel_price"]
	var fill_100_cost = fuel_price * 100
	var fill_required_amount = int(fuel_tank_size - fuel_level)
	var fill_tank_cost = fuel_price * fill_required_amount
	$FuelLevelLabel.text = "Fuel in your tank: " + str(int(ceil(fuel_level)))
	$FuelCapacityLabel.text = "Fuel tank capacity: " + str(fuel_tank_size)
	$FillTankButton.text = "Fill Tank: $" + str(int(ceil(fill_tank_cost)))
	$Fill100Button.text = "Fill 100 Units: $" + str(fill_100_cost)
	$FuelPriceLabel.text = "Fuel price: $" + str(fuel_price) + " / unit" 
	
func _fill_tank():
	var required_amount = int(ceil(fuel_tank_size - fuel_level))
	Global.get_socket_client().buy_fuel(required_amount)
	
func _fill_100():
	Global.get_socket_client().buy_fuel(100)
	
	
