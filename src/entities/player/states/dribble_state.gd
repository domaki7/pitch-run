class_name PlayerDribbleState
extends PlayerState

func enter() -> void:
	ball_control.ball_lost.connect(_on_ball_lost)

func exit() -> void:
	ball_control.ball_lost.disconnect(_on_ball_lost)

func process_physics(delta: float) -> void:
	var direction: Vector2 = get_input_direction()
	movement.apply_movement(direction, delta)
	ball_control.update_facing(direction)

	if direction.length_squared() == 0.0:
		transition_requested.emit(self, &"IdleState")
		return

	if not _is_input_enabled():
		return

	if Input.is_action_just_pressed(&"pass_ball"):
		var ball: RigidBody2D = ball_control.release_ball()
		if ball:
			kick.pass_ball(ball, get_mouse_target())
		return

	if Input.is_action_just_pressed(&"shoot"):
		var ball: RigidBody2D = ball_control.release_ball()
		if ball:
			kick.shoot(ball, get_mouse_target())
		return

	if Input.is_action_just_pressed(&"sprint"):
		if stamina.start_sprint():
			transition_requested.emit(self, &"SprintState")

func _on_ball_lost() -> void:
	transition_requested.emit(self, &"RunState")
