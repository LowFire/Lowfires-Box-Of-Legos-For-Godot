@tool
extends Node2D
class_name Cursor
## A class that represents a cursor in a 2d world. Interacts with instances of [Clickable] and [Hoverable],
## allowing mouse-like interaction with objects that are in the game world. Is meant to be controlled
## by a [CursorController] instance.

## Emitted when this [Cursor] clicks on a [Clickable]. [param obj] is the clickable clicked on.
## [param button] is the mouse button that was clicked.
signal clicked_on(obj: Clickable, button: MouseButton)
## Emitted when this [Cursor] clicks and holds on a [Clickable]. [param obj] is the clickable clicked
## and held on. [param button] is the mouse button being held.
signal held_on(obj: Clickable, button: MouseButton)
## Emitted when this [Cursor] releases a mouse button on a [Clickable] when previously clicked. 
## [param obj] is the clickable released on. [param button] is the mouse button that was released.
signal released_on(obj: Clickable, button: MouseButton)
## Emitted when this [Cursor] enters into a hoverable object. [param obj] is the hoverable the cursor
## entered into.
signal entered_into(obj: Hoverable)
## Emiteed when this [Cursor] exits from a hoverable object [param obj] is the hoverable the cursor
## exited from.
signal exited_from(obj: Hoverable)

## The collision bit mask used to detect hoverable objects. Make sure the collision layer of your
## hoverables are set to the same value so that the cursor can detect them.
@export_flags_2d_physics var hoverable_collision_mask: int:
	get = _get_hoverable_collision_mask,
	set = _set_hoverable_collision_mask

## The collision bit mask used to detect clickable objects. Make sure the collision layer of your
## clickables are set to the same value so that the cursor can detect them.
@export_flags_2d_physics var clickable_collision_mask: int:
	get = _get_clickable_collision_mask,
	set = _set_clickable_collision_mask

## The sprite used to represent the cursor.
@export var cursor_sprite: Texture2D:
	get = _get_cursor_sprite,
	set = _set_cursor_sprite


var _cursor_texture: Texture2D
var _hoverable_collision_mask: int = 1
var _clickable_collision_mask: int = 1
var _current_clickable: Clickable
var _current_hoverable: Hoverable

@onready var _cursor_sprite: Sprite2D = $Sprite2D
@onready var _clickable_raycast: RayCast2D = %ClickableRayCast
@onready var _hoverable_raycast: RayCast2D = %HoverableRayCast


func _ready() -> void:
	_cursor_sprite.texture = _cursor_texture
	_clickable_raycast.collision_mask = _clickable_collision_mask
	_hoverable_raycast.collision_mask = _hoverable_collision_mask


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_check_for_clickables()
	_check_for_hoverables()

## Clicks on the targeted [Clickable] using mouse button [p_button]. Does nothing if this [Cursor]
## is not targeting a clickable. Emits [signal clicked_on] if a clickable was successfully clicked on.
## [signal held] will continuously emit until [method release] is called.
func click(p_button: MouseButton) -> void:
	if not is_instance_valid(_current_clickable):
		return
	
	_current_clickable.click(p_button)
	clicked_on.emit(_current_clickable, p_button)

## Releases the [Clickable] when previously clicked on by [param p_button]. [Signal held] ceases
## to emit when this is called. [signal released_on] is emitted when this is called.
func release(p_button: MouseButton) -> void:
	if not is_instance_valid(_current_clickable):
		return
	
	_current_clickable.release(p_button)
	released_on.emit(_current_clickable, p_button)


func _check_for_clickables() -> void:
	if not _clickable_raycast.is_colliding():
		_release_current_clickable()
		return
	
	var obj = _clickable_raycast.get_collider()
	if obj is Clickable and not is_same(_current_clickable, obj):
		_release_current_clickable()
		_current_clickable = obj
		_current_clickable.held.connect(_on_clickable_held)


func _check_for_hoverables() -> void:
	if not _hoverable_raycast.is_colliding():
		_release_current_hoverable()
		return
	
	var obj = _hoverable_raycast.get_collider()
	if obj is Hoverable and not is_same(_current_hoverable, obj):
		_release_current_hoverable()
		_current_hoverable = obj
		_current_hoverable.enter()
		entered_into.emit(_current_hoverable)


func _release_current_clickable() -> void:
	if not is_instance_valid(_current_clickable):
		return
	
	_current_clickable.held.disconnect(_on_clickable_held)
	
	if _current_clickable.is_clicked(MouseButton.MOUSE_BUTTON_LEFT):
		_current_clickable.release(MouseButton.MOUSE_BUTTON_LEFT)
	if _current_clickable.is_clicked(MouseButton.MOUSE_BUTTON_RIGHT):
		_current_clickable.release(MouseButton.MOUSE_BUTTON_RIGHT)
	if _current_clickable.is_clicked(MouseButton.MOUSE_BUTTON_MIDDLE):
		_current_clickable.release(MouseButton.MOUSE_BUTTON_MIDDLE)
	
	_current_clickable = null


func _release_current_hoverable() -> void:
	if not is_instance_valid(_current_hoverable):
		return
	
	_current_hoverable.exit()
	exited_from.emit(_current_hoverable)
	_current_hoverable = null


func _on_clickable_held(p_button: MouseButton) -> void:
	assert(is_instance_valid(_current_clickable), "Current clickable should be valid.")
	held_on.emit(_current_clickable, p_button)


func _get_cursor_sprite() -> Texture2D:
	if not is_instance_valid(_cursor_sprite):
		return null
	return _cursor_sprite.texture


func _set_cursor_sprite(p_sprite: Texture2D) -> void:
	_cursor_texture = p_sprite
	
	if not is_instance_valid(_cursor_sprite):
		return
	_cursor_sprite.texture = _cursor_texture


func _get_hoverable_collision_mask() -> int:
	return _hoverable_collision_mask


func _set_hoverable_collision_mask(p_mask: int) -> void:
	_hoverable_collision_mask = p_mask
	if not is_instance_valid(_hoverable_raycast):
		return
	
	_hoverable_raycast.collision_mask = _hoverable_collision_mask


func _get_clickable_collision_mask() -> int:
	return _clickable_collision_mask


func _set_clickable_collision_mask(p_mask: int) -> void:
	_clickable_collision_mask = p_mask
	if not is_instance_valid(_clickable_raycast):
		return
	
	_clickable_raycast.collision_mask = _clickable_collision_mask
