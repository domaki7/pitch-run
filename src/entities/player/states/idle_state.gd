class_name PlayerIdleState
extends PlayerState

func enter() -> void:
	ball_control.ball_received.connect(_on_ball_received)

func exit() -> void:
	ball_control.ball_received.disconnect(_on_ball_received)

func process_physics(delta: float) -> void:
	movement.apply_movement(Vector2.ZERO, delta)

	if ball_control.has_ball:
		ball_control.update_facing(player.velocity.normalized())
		if _is_input_enabled():
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

	if _is_input_enabled() and not ball_control.has_ball:
		if Input.is_action_just_pressed(&"tackle"):
			if stamina.current_stamina >= stamina.tackle_cost:
				transition_requested.emit(self, &"TackleState")
				return

	var direction: Vector2 = get_input_direction()
	if direction.length_squared() > 0.0:
		if ball_control.has_ball:
			transition_requested.emit(self, &"DribbleState")
		else:
			transition_requested.emit(self, &"RunState")

func _on_ball_received() -> void:
	transition_requested.emit(self, &"DribbleState")
