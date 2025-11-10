class_name InputTarget
extends Resource

enum InputType {
	PRESSED,
	HELD,
	RELEASED,
}

@export var input: StringName
@export var input_type: InputType
@export var target_path: NodePath
@export var function_name: StringName
