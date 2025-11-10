class_name TriggeringPlayerController
extends Node

var enabled: bool:
	get:
		return _enabled
	set(p_val):
		_enabled = p_val

@export var _input_targets: Array[InputTarget]
@export var _enabled: bool = true


func _process(_delta: float) -> void:
	_check_inputs()


func add_input_target(p_input_target: InputTarget) -> void:
	_input_targets.append(p_input_target)


func remove_input_target(p_input: StringName) -> void:
	for i: int in _input_targets.size():
		var input_target: InputTarget = _input_targets[i]
		if input_target.input == p_input:
			_input_targets.remove_at(i)
			return


func input_target_change_target(p_input: StringName, p_target: NodePath, 
p_func_name: StringName) -> void:
	for i: int in _input_targets.size():
		var input_target: InputTarget = _input_targets[i]
		if input_target.input == p_input:
			input_target.target_path = p_target
			input_target.function_name = p_func_name
			return


func input_target_clear_target(p_input: StringName) -> void:
	for i: int in _input_targets.size():
		var input_target: InputTarget = _input_targets[i]
		if input_target.input == p_input:
			input_target.target_path = ""
			input_target.function_name = ""
			return


func _check_inputs() -> void:
	if not _enabled:
		return
	
	for i: int in _input_targets.size():
		var input_target: InputTarget = _input_targets[i]
		match input_target.input_type:
			InputTarget.InputType.PRESSED:
				if Input.is_action_just_pressed(input_target.input):
					_execute(input_target)
			InputTarget.InputType.HELD:
				if Input.is_action_pressed(input_target.input):
					_execute(input_target)
			InputTarget.InputType.RELEASED:
				if Input.is_action_just_released(input_target.input):
					_execute(input_target)


func _execute(p_input_target: InputTarget) -> void:
	if p_input_target.target_path.is_empty():
		return
	
	if p_input_target.function_name.is_empty():
		push_error("Failed to call function on %s. " % p_input_target.target_path +
				" Function name is empty.")
		return
	
	var target: Node = get_node_or_null(p_input_target.target_path)
	if not is_instance_valid(target):
		push_error("Failed to call function '%s' on '%s'. " % \
				[p_input_target.function_name, p_input_target.target_path] +
				"Target path was not valid.")
		return
	if not target.has_method(p_input_target.function_name):
		push_error("Failed to call function '%s' on '%s'. " % \
				[p_input_target.function_name, p_input_target.target_path] +
				"Target does not have that function.")
		return
	
	target.call(p_input_target.function_name)
