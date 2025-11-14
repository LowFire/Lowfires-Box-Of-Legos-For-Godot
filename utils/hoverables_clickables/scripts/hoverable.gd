extends Area2D
class_name Hoverable

signal cursor_entered()
signal cursor_exited()
signal delay_expired()

@export var delay: float:
	get:
		return _delay_time
	set(p_val):
		_delay_time = p_val

@export var enabled: bool:
	get = _get_enabled,
	set = _set_enabled

var _delay_time: float = 1.0
var _current_time: float
var _enabled: bool = true
var _hovered: bool
var _expired: bool


func _enter_tree() -> void:
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)


func _process(p_delta: float) -> void:
	_tick(p_delta)


func _tick(p_delta: float) -> void:
	if not _enabled or not _hovered:
		return
	
	_current_time -= p_delta
	if _current_time <= 0 and not _expired:
		_expired = true
		delay_expired.emit()


func is_hovered() -> bool:
	return _hovered


func enter() -> void:
	_on_mouse_enter()


func exit() -> void:
	_on_mouse_exit()


func _on_mouse_enter() -> void:
	if not _enabled or _hovered:
		return
	
	_hovered = true
	_expired = false
	_current_time = _delay_time
	cursor_entered.emit()


func _on_mouse_exit() -> void:
	if not _enabled or not _hovered:
		return
	
	_hovered = false
	cursor_exited.emit()


func _set_enabled(p_val: bool) -> void:
	_enabled = p_val
	
	if not _enabled and _hovered:
		_hovered = false
		cursor_exited.emit()


func _get_enabled() -> bool:
	return _enabled
