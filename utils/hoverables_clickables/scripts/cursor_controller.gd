extends Node
class_name CursorController

@export var cursor_left_input: StringName:
	get:
		return _cursor_left_input
	set(p_val):
		_cursor_left_input = p_val

@export var cursor_right_input: StringName:
	get:
		return _cursor_right_input
	set(p_val):
		_cursor_right_input = p_val

@export var cursor_up_input: StringName:
	get:
		return _cursor_up_input
	set(p_val):
		_cursor_up_input = p_val

@export var cursor_down_input: StringName:
	get:
		return _cursor_down_input
	set(p_val):
		_cursor_down_input = p_val

@export var left_click_input: StringName:
	get:
		return _left_click_input
	set(p_val):
		_left_click_input = p_val

@export var right_click_input: StringName:
	get:
		return _right_click_input
	set(p_val):
		_right_click_input = p_val

@export var middle_click_input: StringName:
	get:
		return _middle_click_input
	set(p_val):
		_middle_click_input = p_val

@export var cursor: Cursor:
	get:
		return _cursor
	set(p_val):
		_cursor = p_val

@export var enabled: bool:
	get:
		return _enabled
	set(p_val):
		_enabled = p_val

@export_range(0, 2000, 1, 'prefix:pixels/s') var cursor_x_speed: int:
	get = _get_cursor_x_speed,
	set = _set_cursor_x_speed

@export_range(0, 2000, 1, 'prefix:pixels/s') var cursor_y_speed: int:
	get = _get_cursor_y_speed,
	set = _set_cursor_y_speed


var _cursor_left_input: StringName
var _cursor_right_input: StringName
var _cursor_up_input: StringName
var _cursor_down_input: StringName
var _left_click_input: StringName
var _right_click_input: StringName
var _middle_click_input: StringName
var _cursor: Cursor
var _enabled: bool = true
var _cursor_x_speed: int = 250
var _cursor_y_speed: int = 250


func _process(p_delta: float) -> void:
	_process_input(p_delta)


func _process_input(p_delta: float) -> void:
	if not _enabled or not is_instance_valid(_cursor):
		return
	
	_move_cursor(p_delta)
	_check_inputs()


func _get_cursor_x_speed() -> int:
	return _cursor_x_speed


func _set_cursor_x_speed(p_val: int) -> void:
	if p_val < 0:
		_cursor_x_speed = 0
	else:
		_cursor_x_speed = p_val


func _get_cursor_y_speed() -> int:
	return _cursor_y_speed


func _set_cursor_y_speed(p_val: int) -> void:
	if p_val < 0:
		_cursor_y_speed = 0
	else:
		_cursor_y_speed = p_val


func _move_cursor(p_delta: float) -> void:
	var vel: Vector2 = Input.get_vector(_cursor_left_input, _cursor_right_input, _cursor_up_input,
			_cursor_down_input)
	vel.x *= _cursor_x_speed * p_delta
	vel.y *= _cursor_y_speed * p_delta
	
	_cursor.position += vel


func _check_inputs() -> void:
	if Input.is_action_just_pressed(_left_click_input):
		_cursor.click(MouseButton.MOUSE_BUTTON_LEFT)
	if Input.is_action_just_released(_left_click_input):
		_cursor.release(MouseButton.MOUSE_BUTTON_LEFT)
	
	if Input.is_action_just_pressed(_right_click_input):
		_cursor.click(MouseButton.MOUSE_BUTTON_RIGHT)
	if Input.is_action_just_released(_right_click_input):
		_cursor.release(MouseButton.MOUSE_BUTTON_RIGHT)
	
	if Input.is_action_just_pressed(_middle_click_input):
		_cursor.click(MouseButton.MOUSE_BUTTON_MIDDLE)
	if Input.is_action_just_released(_middle_click_input):
		_cursor.release(MouseButton.MOUSE_BUTTON_MIDDLE)
