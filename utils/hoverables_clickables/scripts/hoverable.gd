@tool
extends Area2D
class_name Hoverable
## A class that allows objects to be "hoverable" by a [Cursor]. 

## Emits when a [Cursor] enters into this [Hoverable].
signal cursor_entered()
## Emits when a [Cursor] exits from this [Hoverable], assuming that it had previously entered it.
signal cursor_exited()

## Sets whether this [Hoverable] is enabled.
@export var enabled: bool:
	get = _get_enabled,
	set = _set_enabled

var _enabled: bool = true
var _hovered: bool


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)


## Returns if a [Cursor] is currently hovering over this [Hoverable].
func is_hovered() -> bool:
	return _hovered


## Called to signal that a [Cursor] had entered this [Hoverable]. Mostly used
## to allow a cursor to interface with this hoverable.
func enter() -> void:
	_on_mouse_enter()


## Called to signal that a [Cursor] had exited this [Hoverable]. Mostly used
## to allow a cursor to interface with this hoverable.
func exit() -> void:
	_on_mouse_exit()


func _on_mouse_enter() -> void:
	if Engine.is_editor_hint():
		return
	
	if not _enabled or _hovered:
		return
	
	_hovered = true
	cursor_entered.emit()


func _on_mouse_exit() -> void:
	if Engine.is_editor_hint():
		return
	
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
