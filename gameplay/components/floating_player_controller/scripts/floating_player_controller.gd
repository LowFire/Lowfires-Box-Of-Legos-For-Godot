class_name FloatingPlayerController
extends Node

enum MoveMode {
	SLIDE,
	COLLIDE,
}

const INSTANTANEOUS: int = -1

var max_speed: int:
	get:
		return _max_speed
	set(p_val):
		_max_speed = p_val

var acceleration_time: int:
	get:
		return _acceleration_time
	set(p_val):
		_acceleration_time = p_val
		_acceleration = _calc_accel_decel(_acceleration_time)

var deceleration_time: int:
	get:
		return _deceleration_time
	set(p_val):
		_deceleration_time = p_val
		_deceleration = _calc_accel_decel(_deceleration_time)

var up_input: StringName:
	get:
		return _up_input
	set(p_val):
		_up_input = p_val

var down_input: StringName:
	get:
		return _down_input
	set(p_val):
		_down_input = p_val

var left_input: StringName:
	get:
		return _left_input
	set(p_val):
		_left_input = p_val

var right_input: StringName:
	get:
		return _right_input
	set(p_val):
		_right_input = p_val

var enabled: bool:
	get:
		return _enabled
	set(p_val):
		_enabled = p_val

var diagonal_movement: bool:
	get:
		return _diagonal_movement
	set(p_val):
		_diagonal_movement = p_val

var target: CharacterBody2D:
	get:
		return _target
	set(p_val):
		_target = p_val
		if is_instance_valid(_target):
			_target.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

var move_mode: MoveMode:
	get:
		return _move_mode
	set(p_val):
		_move_mode = p_val

@export_custom(PROPERTY_HINT_NONE, "suffix:pixles/s") var _max_speed: int = 300
@export_range(0, 10_000, 1, "suffix:milliseconds") var _acceleration_time: int = 500
@export_range(0, 10_000, 1, "suffix:milliseconds") var _deceleration_time: int = 500
@export var _up_input: StringName
@export var _down_input: StringName
@export var _left_input: StringName
@export var _right_input: StringName
@export var _enabled: bool = true
@export var _diagonal_movement: bool = true
@export var _target: CharacterBody2D
@export var _move_mode: MoveMode

@onready var _acceleration: float = _calc_accel_decel(_acceleration_time)
@onready var _deceleration: float = _calc_accel_decel(_deceleration_time)

var _inputs_pressed: Array[StringName]


func _ready() -> void:
	if not is_instance_valid(_target):
		push_error("Target for floating player controller is not valid. Make sure to set it " +
				"in the inspector.")


func _process(_delta) -> void:
	if not _diagonal_movement:
		_check_inputs()


func _physics_process(p_delta: float) -> void:
	_update(p_delta)


func _update(p_delta: float) -> void:
	if not is_instance_valid(_target):
		return
	if not _enabled:
		return
	
	var direction: Vector2 = _get_direction()
	if direction != Vector2.ZERO:
		_accelerate(direction, p_delta)
	else:
		_decelerate(p_delta)
	
	match _move_mode:
		MoveMode.SLIDE:
			_target.move_and_slide()
		MoveMode.COLLIDE:
			_target.move_and_collide(_target.velocity * p_delta)


func _accelerate(p_direction: Vector2, p_delta: float) -> void:
	if _acceleration == INSTANTANEOUS:
		_target.velocity = p_direction * _max_speed
	else:
		_target.velocity = _target.velocity.move_toward(p_direction * _max_speed, 
			_acceleration * p_delta)


func _decelerate(p_delta: float) -> void:
	if _deceleration == INSTANTANEOUS:
		_target.velocity = Vector2.ZERO
	else:
		_target.velocity = _target.velocity.move_toward(Vector2.ZERO, _deceleration * p_delta)


func _get_direction() -> Vector2:
	var ret := Vector2()
	
	if _diagonal_movement:
		ret =  Input.get_vector(_left_input, _right_input, _up_input, _down_input)
	else:
		if _inputs_pressed.size() == 0:
			return ret
		
		var input_last_pressed = _inputs_pressed.back()
		match input_last_pressed:
			_left_input:
				return Vector2.LEFT
			_right_input:
				return Vector2.RIGHT
			_up_input:
				return Vector2.UP
			_down_input:
				return Vector2.DOWN
	
	return ret

func _check_inputs() -> void:
	if Input.is_action_just_pressed(_up_input):
		_inputs_pressed.append(_up_input)
	if Input.is_action_just_pressed(_down_input):
		_inputs_pressed.append(_down_input)
	if Input.is_action_just_pressed(_left_input):
		_inputs_pressed.append(_left_input)
	if Input.is_action_just_pressed(_right_input):
		_inputs_pressed.append(_right_input)
	
	if Input.is_action_just_released(_up_input):
		_inputs_pressed.erase(_up_input)
	if Input.is_action_just_released(_down_input):
		_inputs_pressed.erase(_down_input)
	if Input.is_action_just_released(_left_input):
		_inputs_pressed.erase(_left_input)
	if Input.is_action_just_released(_right_input):
		_inputs_pressed.erase(_right_input)


func _calc_accel_decel(p_time: int) -> float:
	if p_time <= 0:
		return INSTANTANEOUS
	
	var time: float = p_time / 1000.0 # p_time is in miliseconds. Convert to seconds.
	return _max_speed / time
