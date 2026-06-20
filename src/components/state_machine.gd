class_name StateMachine
extends Node

signal transitioned(old_state_name: StringName, new_state_name: StringName)

var current_state: State = null
var _states: Dictionary = {}

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)
	for child in get_children():
		if child is State:
			_states[child.name] = child
			child.transition_requested.connect(_on_transition_requested)

func _process(delta: float) -> void:
	if current_state:
		current_state.process_frame(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.process_physics(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func transition_to(target_state_name: StringName) -> void:
	var target_state: State = _states.get(target_state_name)
	if target_state == null:
		push_warning("State not found: " + str(target_state_name))
		return
	var old_name: StringName = current_state.name if current_state else &""
	if current_state:
		current_state.exit()
	current_state = target_state
	current_state.enter()
	set_process(true)
	set_physics_process(true)
	set_process_unhandled_input(true)
	transitioned.emit(old_name, target_state.name)

func _on_transition_requested(from: State, to: StringName) -> void:
	if from == current_state:
		transition_to(to)
