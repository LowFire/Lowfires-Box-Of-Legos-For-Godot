@tool
extends Node
class_name CursorController

## Sets whether or not to use the hardware mouse. This means that the cursor will follow the hardware
## mouse instead of relying on input map bindings to move the cursor around.
@export var use_hardware_mouse: bool:
	get = _get_use_hardware_mouse,
	set = _set_use_hardware_mouse

## The name of the input map used to move the cursor to the left.
@export var cursor_left_input: StringName:
	get:
		return _cursor_left_input
	set(p_val):
		_cursor_left_input = p_val

## The name of the input map used to move the cursor to the right.
@export var cursor_right_input: StringName:
	get:
		return _cursor_right_input
	set(p_val):
		_cursor_right_input = p_val

## The name of the input map used to move the cursor to the up.
@export var cursor_up_input: StringName:
	get:
		return _cursor_up_input
	set(p_val):
		_cursor_up_input = p_val

## The name of the input map used to move the cursor to the down.
@export var cursor_down_input: StringName:
	get:
		return _cursor_down_input
	set(p_val):
		_cursor_down_input = p_val

## The name of the input map used to emulate left clicking.
@export var left_click_input: StringName:
	get:
		return _left_click_input
	set(p_val):
		_left_click_input = p_val

## The name of the input map used to emulate right clicking.
@export var right_click_input: StringName:
	get:
		return _right_click_input
	set(p_val):
		_right_click_input = p_val

## The name of the input map used to emulate middle clicking.
@export var middle_click_input: StringName:
	get:
		return _middle_click_input
	set(p_val):
		_middle_click_input = p_val

## The target [Cursor] this controller will move around and simulate mouse clicks with. This must
## be set to a valid value or else the controller will not work.
@export var cursor: Cursor:
	get:
		return _cursor
	set(p_val):
		_cursor = p_val

## Sets whether or not this [CursorController] is enabled
@export var enabled: bool:
	get:
		return _enabled
	set(p_val):
		_enabled = p_val

## The cursor horizontal speed used when using input map controls. This does not effect
## the speed at which the cursor follows the hardware mouse.
@export_range(0, 2000, 1, 'prefix:pixels/s') var cursor_x_speed: int:
	get = _get_cursor_x_speed,
	set = _set_cursor_x_speed

## The cursor vertial speed used when using input map controls. This does not effect
## the speed at which the cursor follows the hardware mouse.
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
var _use_hardware_mouse: bool


func _process(p_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_process_input(p_delta)

## Teleports [member cursor] to the position [param p_screen_pos]. Position must be in
## viewport coordinates.
func warp_cursor(p_screen_pos: Vector2) -> void:
	if not enabled or not is_instance_valid(_cursor):
		return
	
	if not _use_hardware_mouse:
		var view_to_world: Transform2D = _cursor.get_canvas_transform().affine_inverse()
		_cursor.global_position = view_to_world * p_screen_pos
	else:
		get_viewport().warp_mouse(p_screen_pos)


func _process_input(p_delta: float) -> void:
	if not _enabled or not is_instance_valid(_cursor):
		return
	
	if not _use_hardware_mouse:
		_move_cursor(p_delta)
	else:
		_track_hardware_mouse()
	
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


func _track_hardware_mouse() -> void:
	assert(enabled, "Controller should be enabled")
	assert(is_instance_valid(_cursor), "Cursor should be valid")
	assert(_use_hardware_mouse, "Should be using hardware mouse.")
	
	_cursor.global_position = _cursor.get_global_mouse_position()


func _get_use_hardware_mouse() -> bool:
	return _use_hardware_mouse


func _set_use_hardware_mouse(p_val: bool) -> void:
	_use_hardware_mouse = p_val
