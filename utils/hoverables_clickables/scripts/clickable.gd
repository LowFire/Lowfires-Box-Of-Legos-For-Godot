extends Area2D
class_name Clickable

signal clicked(p_button: MouseButton)
signal held(p_button: MouseButton)
signal released(p_button: MouseButton)

@export_range(0, 5000) var hold_tick_rate: int:
	get = _get_hold_tick_rate,
	set = _set_hold_tick_rate

@export var enabled: bool:
	get = _get_enabled,
	set = _set_enabled

var _left_clicked: bool
var _right_clicked: bool
var _middle_clicked: bool
var _enabled: bool = true
var _tick_time: float = 0.1
var _time_till_tick: float


func _process(p_delta: float) -> void:
	_tick(p_delta)


func click(p_button: MouseButton) -> void:
	if not _enabled:
		return
	
	if not _one_button_is_clicked():
		_time_till_tick = _tick_time

	match p_button:
		MouseButton.MOUSE_BUTTON_LEFT:
			if not _left_clicked:
				_left_clicked = true
				clicked.emit(MouseButton.MOUSE_BUTTON_LEFT)
		MouseButton.MOUSE_BUTTON_RIGHT:
			if not _right_clicked:
				_right_clicked = true
				clicked.emit(MouseButton.MOUSE_BUTTON_RIGHT)
		MouseButton.MOUSE_BUTTON_MIDDLE:
			if not _middle_clicked:
				_middle_clicked = true
				clicked.emit(MouseButton.MOUSE_BUTTON_MIDDLE)


func release(p_button: MouseButton) -> void:
	if not _enabled:
		return
	
	match p_button:
		MouseButton.MOUSE_BUTTON_LEFT:
			if _left_clicked:
				_left_clicked = false
				released.emit(MouseButton.MOUSE_BUTTON_LEFT)
		MouseButton.MOUSE_BUTTON_RIGHT:
			if _right_clicked:
				_right_clicked = false
				released.emit(MouseButton.MOUSE_BUTTON_RIGHT)
		MouseButton.MOUSE_BUTTON_MIDDLE:
			if _middle_clicked:
				_middle_clicked = false
				released.emit(MouseButton.MOUSE_BUTTON_MIDDLE)
	


func is_clicked(p_button: MouseButton) -> bool:
	match p_button:
		MouseButton.MOUSE_BUTTON_LEFT:
			if _left_clicked:
				return true
			return false
		MouseButton.MOUSE_BUTTON_RIGHT:
			if _right_clicked:
				return true
			return false
		MouseButton.MOUSE_BUTTON_MIDDLE:
			if _middle_clicked:
				return true
			return false
		_:
			return false


func _set_hold_tick_rate(p_val: int) -> void:
	if p_val <= 0:
		_tick_time = 60
	
	_tick_time = 60.0 / p_val


func _get_hold_tick_rate() -> int:
	@warning_ignore("narrowing_conversion")
	return 60 / _tick_time


func _get_enabled() -> bool:
	return _enabled


func _set_enabled(p_val: bool) -> void:
	_enabled = p_val
	
	if not _enabled:
		_release_all()


func _tick(p_delta: float) -> void:
	if not _enabled or not _one_button_is_clicked():
		return
	
	_time_till_tick -= p_delta
	if _time_till_tick <= 0:
		if _left_clicked:
			held.emit(MouseButton.MOUSE_BUTTON_LEFT)
		if _right_clicked:
			held.emit(MouseButton.MOUSE_BUTTON_RIGHT)
		if _middle_clicked:
			held.emit(MouseButton.MOUSE_BUTTON_MIDDLE)
		_time_till_tick = _tick_time


func _input_event(_viewport, p_event: InputEvent, _shape_idx) -> void:
	if not _enabled or not p_event is InputEventMouseButton:
		return
	
	var mouse_button_event := p_event as InputEventMouseButton
	if mouse_button_event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if mouse_button_event.pressed:
			_left_clicked = true
			clicked.emit(MouseButton.MOUSE_BUTTON_LEFT)
		else:
			_left_clicked = false
			released.emit(MouseButton.MOUSE_BUTTON_LEFT)
	elif mouse_button_event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
		if mouse_button_event.pressed:
			_right_clicked = true
			clicked.emit(MouseButton.MOUSE_BUTTON_RIGHT)
		else:
			_right_clicked = false
			released.emit(MouseButton.MOUSE_BUTTON_RIGHT)
	elif mouse_button_event.button_index == MouseButton.MOUSE_BUTTON_MIDDLE:
		if mouse_button_event.pressed:
			_middle_clicked = true
			clicked.emit(MouseButton.MOUSE_BUTTON_MIDDLE)
		else:
			_middle_clicked = false
			released.emit(MouseButton.MOUSE_BUTTON_MIDDLE)


func _mouse_exit() -> void:
	if not enabled:
		return
	
	_release_all()


func _release_all() -> void:
	if _left_clicked:
		_left_clicked = false
		released.emit(MouseButton.MOUSE_BUTTON_LEFT)
	
	if _right_clicked:
		_right_clicked = false
		released.emit(MouseButton.MOUSE_BUTTON_RIGHT)
	
	if _middle_clicked:
		_middle_clicked = false
		released.emit(MouseButton.MOUSE_BUTTON_MIDDLE)


func _one_button_is_clicked() -> bool:
	return _left_clicked or _right_clicked or _middle_clicked
