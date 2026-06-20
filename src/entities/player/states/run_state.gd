class_name PlayerRunState
extends PlayerState

func enter() -> void:
	ball_control.ball_received.connect(_on_ball_received)

func exit() -> void:
	ball_control.ball_received.disconnect(_on_ball_received)

func process_physics(delta: float) -> void:
	var direction: Vector2 = get_input_direction()
	movement.apply_movement(direction, delta)

	if direction.length_squared() == 0.0:
		transition_requested.emit(self, &"IdleState")
		return

	if _is_input_enabled() and Input.is_action_just_pressed(&"sprint"):
		if stamina.start_sprint():
			transition_requested.emit(self, &"SprintState")

func _on_ball_received() -> void:
	transition_requested.emit(self, &"DribbleState")
