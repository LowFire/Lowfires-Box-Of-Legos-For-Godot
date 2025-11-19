@tool
extends Area2D
class_name Clickable
## A node that is clickable by the [Cursor]. Is clickable by either a hardware or software cursor.
## Inherits from [Area2D] so that it can detect inputs from the hardware mouse. Must be [Area2D.input_pickable]
## in order to work. The [Cursor] can also click on it using input map inputs received from [CursorController]
## Mouse buttons that are supported are [enum MouseButton.MOUSE_BUTTON_LEFT], [enum MouseButton.MOUSE_BUTTON_RIGHT],
## and [enum MouseButton.MOUSE_BUTTON_MIDDLE]

## Emitted with this [Clickable] is clicked on by the cursor. [param p_button] is the button that
## was used to click on this [Clickable].
signal clicked(p_button: MouseButton)
## Emitted when this [Clickable] is clicked on and held by the cursor. Emits at a rate determined by
## [member hold_tick_rate]. [param p_button] is the mouse button being held.
signal held(p_button: MouseButton)
## Emitted when this [Clickable] is released by the cursor after being previously clicked on.
## [param p_button] is the button that was released on this [Clickable].
signal released(p_button: MouseButton)

## The rate in ticks per minute in which [signal held] is emitted when a button is clicked and held
## on this [Clickable].
@export_range(0, 5000) var hold_tick_rate: int:
	get = _get_hold_tick_rate,
	set = _set_hold_tick_rate

## Sets whether or not this clickable is enabled.
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
	if Engine.is_editor_hint():
		return
	
	_tick(p_delta)


## Clicks on this [Clickable], using mouse button [param p_button]. This is mostly used by the [Cursor]
## to interface with this [Clickable]
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

## Releases the button [param p_button] on this [Clickable] when previously clicked on. This is
## mostly used by the [Cursor] to interface with this [Clickable].
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
	

## Checks if [param p_button] is clicked.
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
	if Engine.is_editor_hint():
		return
	
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
