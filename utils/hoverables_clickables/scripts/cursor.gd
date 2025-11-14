extends Node2D
class_name Cursor

@export var monitor_world_nodes: bool:
	get:
		return _monitor_world_nodes
	set(p_val):
		_monitor_world_nodes = p_val

@export var monitor_ui_nodes: bool:
	get:
		return _monitor_ui_nodes
	set(p_val):
		_monitor_ui_nodes = p_val

@export_flags_2d_physics var collision_mask: int:
	get:
		return _collision_mask
	set(p_val):
		_collision_mask = p_val

var _monitor_ui_nodes: bool = true
var _monitor_world_nodes: bool = true
var _collision_mask: int = 1

@onready var _raycast_2d: RayCast2D = %WorldRayCast
@onready var _cursor_sprite: Sprite2D = $Sprite2D


func click(p_button: MouseButton) -> void:
	pass


func release(p_button: MouseButton) -> void:
	pass
