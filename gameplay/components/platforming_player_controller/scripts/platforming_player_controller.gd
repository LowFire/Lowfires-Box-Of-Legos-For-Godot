@tool
class_name PlatformingPlayerController
extends Node

const INSTANTANEOUS: int = -1
const DISABLED: int = 0

@export
var target: CharacterBody2D:
	get:
		return _target
	set(p_val):
		if is_instance_valid(_target):
			_detach_slope_checker_from_target()
		
		_target = p_val
		
		if is_instance_valid(_target):
			_attach_slope_checker_to_target()

@export
var enabled: bool:
	get:
		return _enabled
	set(p_val):
		_enabled = p_val

@export_group("Platforming Physics")
@export_range(0, 2000, 1, "suffix:pixles/s") 
var max_speed: int:
	get:
		return _speed
	set(p_val):
		if p_val <= 0:
			_speed = 0
		else:
			_speed = p_val
		
		_g_accel_time = _calc_accel_decel_time(_g_accel)
		_g_decel_time = _calc_accel_decel_time(_g_decel)
		_a_accel_time = _calc_accel_decel_time(_a_accel)
		_a_decel_time = _calc_accel_decel_time(_a_decel)

@export_range(0, 2000, 1, "suffix:pixles/s") 
var max_fall_speed: int:
	get:
		return _max_fall_speed
	set(p_val):
		if p_val <= 0:
			_max_fall_speed = 0
		else:
			_max_fall_speed = p_val

@export_range(-1, 10_000, 1, "suffix:milliseconds") 
var ground_acceleration_time: int:
	get:
		return _g_accel_time
	set(p_val):
		_g_accel_time = p_val
		_g_accel = _calc_accel_decel_rate(_g_accel_time)

@export_range(-1, 10_000, 1, "suffix:milliseconds") 
var ground_deceleration_time: int:
	get:
		return _g_decel_time
	set(p_val):
		_g_decel_time = p_val
		_g_decel = _calc_accel_decel_rate(_g_decel_time)

@export_range(-1, 10_000, 1, "suffix:milliseconds") 
var air_acceleration_time: int:
	get:
		return _a_accel_time
	set(p_val):
		_a_accel_time = p_val
		_a_accel = _calc_accel_decel_rate(_a_accel_time)

@export_range(-1, 10_000, 1, "suffix:milliseconds") 
var air_deceleration_time: int:
	get:
		return _a_decel_time
	set(p_val):
		_a_decel_time = p_val
		_a_decel = _calc_accel_decel_rate(_a_decel_time)

@export_range(-1, 10_000, 1, "suffix:pixels/s") 
var ground_acceleration: int:
	get:
		return _g_accel
	set(p_val):
		if p_val <= -1:
			_g_accel = INSTANTANEOUS
		else:
			_g_accel = p_val
			_g_accel_time = _calc_accel_decel_time(_g_accel)

@export_range(-1, 10_000, 1, "suffix:pixels/s") 
var ground_deceleration: int:
	get:
		return _g_decel
	set(p_val):
		if p_val <= -1:
			_g_decel = INSTANTANEOUS
		else:
			_g_decel = p_val
			_g_decel_time = _calc_accel_decel_time(_g_decel)

@export_range(-1, 10_000, 1, "suffix:pixels/s") 
var air_acceelration: int:
	get:
		return _a_accel
	set(p_val):
		if p_val <= -1:
			_a_accel = INSTANTANEOUS
		else:
			_a_accel = p_val
			_a_accel_time = _calc_accel_decel_time(_a_accel)

@export_range(-1, 10_000, 1, "suffix:pixels/s") 
var air_deceleration: int:
	get:
		return _a_decel
	set(p_val):
		if p_val <= -1:
			_a_decel = INSTANTANEOUS
		else:
			_a_decel = p_val
			_a_decel_time = _calc_accel_decel_time(_a_decel)

@export_range(0, 2000, 1, "suffix:pixels/s") 
var jump_strength: int:
	get:
		return _jump_strength
	set(p_val):
		if p_val <= 0:
			_jump_strength = 0
		else:
			_jump_strength = p_val

@export_range(0, 2000, 1, "suffix:pixels/s") 
var jumping_gravity: int:
	get:
		return _jumping_gravity
	set(p_val):
		if p_val <= 0:
			_jumping_gravity = 0
		else:
			_jumping_gravity = p_val

@export_range(0, 2000, 1, "suffix:pixels/s") 
var falling_gravity: int:
	get:
		return _falling_gravity
	set(p_val):
		if p_val <= 0:
			_falling_gravity = 0
		else:
			_falling_gravity = p_val

@export_subgroup("Buffers")
var jump_time_buffer: int:
	get:
		return _jump_time_buffer
	set(p_val):
		if p_val <= 0:
			_jump_time_buffer = 0
		else:
			_jump_time_buffer = p_val

@export_group("Inputs")
@export
var left_input: StringName:
	get:
		return _left_input
	set(p_val):
		_left_input = p_val

@export
var right_input: StringName:
	get:
		return _right_input
	set(p_val):
		_right_input = p_val

@export
var jump_input: StringName:
	get:
		return _jump_input
	set(p_val):
		_jump_input = p_val

var _target: CharacterBody2D
var _enabled: bool = true
var _left_input: StringName
var _right_input: StringName
var _jump_input: StringName
var _speed: int = 300
var _max_fall_speed: int = 1000
var _jump_strength: int = 500
var _jumping_gravity: int = 900
var _falling_gravity: int = 1200
var _jump_time_buffer: int = 100
var _g_accel_time: int = 200
var _g_decel_time: int = 200
var _a_accel_time: int = 500
var _a_decel_time: int = 10_000
var _current_buffer_time: float
var _jumping: bool
var _latest_y_vel: float
var _latest_platform_vel: Vector2
var _is_grounded: bool
var _slope_checker: ShapeCast2D
var _max_left_speed: float
var _max_right_speed: float

@onready var _g_accel: int = _calc_accel_decel_rate(_g_accel_time)
@onready var _g_decel: int = _calc_accel_decel_rate(_g_decel_time)
@onready var _a_accel: int = _calc_accel_decel_rate(_a_accel_time)
@onready var _a_decel: int = _calc_accel_decel_rate(_a_decel_time)

func _ready() -> void:
	if not is_instance_valid(_target):
		push_error("Target is not valid. Be sure to set the controller's target in the inspector.")
		return
	
	
	if is_instance_valid(_target) and not Engine.is_editor_hint():
		_attach_slope_checker_to_target()


func _physics_process(p_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_check_real_y_vel()
	_update(p_delta)
	_check_inputs()
	_apply_gravity(p_delta)


func _update(p_delta: float) -> void:
	if not is_instance_valid(_target):
		return
	if not _enabled:
		return
	
	_check_on_ground(p_delta)
	_check_on_wall()
	
	var direction: float = Input.get_axis(_left_input, _right_input)
	if direction != 0:
		_accelerate(direction, p_delta)
	else:
		_decelerate(p_delta)
	
	_target.move_and_slide()


func _accelerate(p_direction: float, p_delta: float) -> void:
	assert(is_instance_valid(_target))
	
	var x_vel := 0.0
	if _target.is_on_floor(): # use ground acceleration
		x_vel = move_toward(_target.velocity.x, _speed * p_direction, 
				_g_accel * p_delta)
	else: # use air acceleration
		if p_direction == 1:
			x_vel = move_toward(_target.velocity.x, _max_right_speed, _a_accel * p_delta)
		else:
			x_vel = move_toward(_target.velocity.x, -_max_left_speed, _a_accel * p_delta)
	
	_target.velocity.x = x_vel


func _decelerate(p_delta: float) -> void:
	assert(is_instance_valid(_target))
	
	var x_vel := 0.0
	if _target.is_on_floor(): # use ground deceleration
		x_vel = move_toward(_target.velocity.x, 0.0, _g_decel * p_delta)
	else: # use air deceleration
		x_vel = move_toward(_target.velocity.x, 0.0, _a_decel * p_delta)
	
	_target.velocity.x = x_vel


func _apply_gravity(p_delta: float) -> void:
	if not is_instance_valid(_target):
		return
	if not _enabled:
		return
	if _target.is_on_floor() and not _jumping:
		_target.velocity.y = 0
		return
	
	var y_vel: float = 0.0 
	if _jumping: # use jumping gravity
		y_vel = move_toward(_target.velocity.y, _max_fall_speed, _jumping_gravity * p_delta)
	else: # use falling gravity
		y_vel = move_toward(_target.velocity.y, _max_fall_speed, _falling_gravity * p_delta)
	
	_target.velocity.y = y_vel


func _check_inputs() -> void:
	if not is_instance_valid(_target):
		return
	if not _enabled:
		return
	
	if Input.is_action_just_pressed(_jump_input) and _can_jump():
		if not _jumping:
			_jumping = true 
			_target.velocity.y -= _jump_strength
	
	if Input.is_action_just_released(_jump_input):
		if _jumping:
			_jumping = false
			if _target.velocity.y < 0: # We just want to make sure the character isn't actively falling.
				_target.velocity.y = _latest_platform_vel.y


func _calc_accel_decel_rate(p_time: int) -> int:
	if p_time == 0:
		return INSTANTANEOUS
	if p_time <= -1:
		return DISABLED
	
	var _converted_time: float = p_time / 1000.0 # p_time is in milliseconds. Convert to seconds.
	@warning_ignore("narrowing_conversion")
	return _speed / _converted_time


func _calc_accel_decel_time(p_rate: int) -> int:
	if p_rate == DISABLED:
		return -1
	if p_rate <= INSTANTANEOUS:
		return 0
	
	@warning_ignore("narrowing_conversion")
	var ret: int = 1000.0 * (float(_speed) / p_rate) # converts to milliseconds
	return ret


func _can_jump() -> bool:
	return _current_buffer_time > 0


func _check_on_ground(p_delta: float) -> void:
	if _target.is_on_floor():
		_latest_platform_vel = _target.get_platform_velocity()
		var platform_dir: int = sign(_latest_platform_vel.x)
		if platform_dir == 0:
			_max_left_speed = _speed
			_max_right_speed = _speed
		else:
			_max_left_speed = _speed - _latest_platform_vel.x
			_max_right_speed = _speed + _latest_platform_vel.x
		
		if not _is_grounded:
			_is_grounded = true
			_target.velocity.x -= _latest_platform_vel.x
		
		_current_buffer_time = _jump_time_buffer / 1000.0
	else:
		if _is_grounded:
			_is_grounded = false
			if not _jumping:
				_target.velocity.y = _latest_y_vel
		
		_current_buffer_time -= p_delta


func _check_on_wall() -> void:
	pass
	if _target.is_on_wall():
		var platform_vel: Vector2 = _target.get_platform_velocity()
		_target.velocity.x = platform_vel.x


func _attach_slope_checker_to_target() -> void:
	assert(is_instance_valid(_target))
	_slope_checker = ShapeCast2D.new()
	var check_shape := RectangleShape2D.new()
	_slope_checker.shape = check_shape
	var target_body_rect = _target.shape_owner_get_shape(0,0).get_rect()
	_slope_checker.target_position = Vector2(0, 10 + (target_body_rect.size.y / 2))
	check_shape.size = Vector2(target_body_rect.size.x - 20, 5)
	_slope_checker.collision_mask = _target.platform_floor_layers
	_target.add_child(_slope_checker)


func _detach_slope_checker_from_target() -> void:
	_slope_checker.queue_free()


func _check_real_y_vel() -> void:
	if not is_instance_valid(_target) or not _slope_checker.is_colliding():
		return
	
	if _jumping:
		_latest_y_vel = 0.0
	else:
		_latest_y_vel = _target.get_real_velocity().y
