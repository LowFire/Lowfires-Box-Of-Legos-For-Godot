extends Node
class_name CursorObserver
## A class that observes a target [Cursor], allowing interested objects to get
## notifications on what the cursor is clicking on, entering into, exiting from,
## and so forth. 

## Emits when the target cursor emits it's [Cursor.clicked_on] signal
signal clicked_on(obj: Clickable, button: MouseButton)
## Emits when the target cursor emits it's [Cursor.held_on] signal
signal held_on(obj: Clickable, button: MouseButton)
## Emits when the target cursor emits it's [Cursor.released_on] signal
signal released_on(obj: Clickable, button: MouseButton)
## Emits when the target cursor emits it's [Cursor.exited_from] signal
signal exited_from(obj: Hoverable)
## Emits when the target cursor emits it's [Cursor.entered_into] signal
signal entered_into(obj: Hoverable)

## The cursor that this observer will be observing.
@export var target_cursor: Cursor:
	get = _get_target_cursor,
	set = _set_target_cursor

var _target_cursor: Cursor


func _get_target_cursor() -> Cursor:
	return _target_cursor


func _set_target_cursor(p_cursor: Cursor) -> void:
	if is_instance_valid(_target_cursor):
		_disconnect_from_current_cursor()
	
	_target_cursor = p_cursor
	
	if is_instance_valid(_target_cursor):
		_connect_to_current_cursor()


func _on_cursor_clicked_on(p_obj: Clickable, p_button: MouseButton) -> void:
	clicked_on.emit(p_obj, p_button)


func _on_cursor_held_on(p_obj: Clickable, p_button: MouseButton) -> void:
	held_on.emit(p_obj, p_button)


func _on_cursor_released_on(p_obj: Clickable, p_button: MouseButton) -> void:
	released_on.emit(p_obj, p_button)


func _on_cursor_exited_from(p_obj: Hoverable) -> void:
	exited_from.emit(p_obj)


func _on_cursor_entered_into(p_obj: Hoverable) -> void:
	entered_into.emit(p_obj)


func _disconnect_from_current_cursor() -> void:
	assert(is_instance_valid(_target_cursor), "Target cursor should be valid.")
	
	_target_cursor.clicked_on.disconnect(_on_cursor_clicked_on)
	_target_cursor.held_on.disconnect(_on_cursor_held_on)
	_target_cursor.released_on.disconnect(_on_cursor_released_on)
	_target_cursor.entered_into.disconnect(_on_cursor_entered_into)
	_target_cursor.exited_from.disconnect(_on_cursor_exited_from)


func _connect_to_current_cursor() -> void:
	assert(is_instance_valid(_target_cursor), "Target cursor should be valid.")
	
	_target_cursor.clicked_on.connect(_on_cursor_clicked_on)
	_target_cursor.held_on.connect(_on_cursor_held_on)
	_target_cursor.released_on.connect(_on_cursor_released_on)
	_target_cursor.entered_into.connect(_on_cursor_entered_into)
	_target_cursor.exited_from.connect(_on_cursor_exited_from)
