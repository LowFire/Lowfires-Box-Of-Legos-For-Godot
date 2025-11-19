extends Label
class_name NumberCounter

signal updated()

@export var value: float:
	get = _get_value,
	set = _set_value

@export_range(0, 10, 1, "prefix:characters") var percision: int:
	get = _get_percision,
	set = _set_percision

@export var update_curve: Curve:
	get:
		return _update_curve
	set(p_val):
		_update_curve = p_val

var _value: float
var _percision: int
var _update_curve: Curve
var _progress: float
var _from: float


func _process(p_delta: float) -> void:
	_tick(p_delta)


func _tick(p_delta: float) -> void:
	if _progress >= update_curve.max_domain:
		return
	
	var sample: float = _update_curve.sample(_progress)
	var current: float = lerp(_from, _value, sample)
	_update_label(current)
	_progress += p_delta


func _update_label(p_current: float) -> void:
	var format_str: String = "%0.{percision}f".format({"percision": str(_percision)})
	var final_str: String = format_str % p_current
	text = final_str


func _get_percision() -> int:
	return _percision


func _set_percision(p_val: int) -> void:
	if p_val < 0:
		_percision = 0
	else:
		_percision = p_val


func _get_value() -> float:
	return _value


func _set_value(p_val: float) -> void:
	_from = _value
	_progress = 0
	_value = p_val
