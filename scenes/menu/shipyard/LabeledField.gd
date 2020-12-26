extends HBoxContainer	

export var field_name: String

func _ready():
	$FieldName.text = field_name + ":"

func set_field_value(field_value):
	$FieldValue.text = str(field_value)
