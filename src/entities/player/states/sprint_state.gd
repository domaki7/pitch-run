class_name PlayerSprintState
extends PlayerState

func enter() -> void:
	stamina.stamina_depleted.connect(_on_stamina_depleted)
	ball_control.ball_received.connect(_on_ball_received)
	ball_control.ball_lost.connect(_on_ball_lost)

func exit() -> void:
	stamina.stop_sprint()
	stamina.stamina_depleted.disconnect(_on_stamina_depleted)
	ball_control.ball_received.disconnect(_on_ball_received)
	ball_control.ball_lost.disconnect(_on_ball_lost)

func process_physics(delta: float) -> void:
	var direction: Vector2 = get_input_direction()
	movement.apply_movement(direction, delta, true)

	if ball_control.has_ball:
		ball_control.update_facing(direction)

	if direction.length_squared() == 0.0:
		_drop_to_base_state()
		return

	if not _is_input_enabled():
		return

	if not Input.is_action_pressed(&"sprint"):
		_drop_to_base_state()
		return

	if ball_control.has_ball:
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

func _drop_to_base_state() -> void:
	if ball_control.has_ball:
		transition_requested.emit(self, &"DribbleState")
	else:
		transition_requested.emit(self, &"RunState")

func _on_stamina_depleted() -> void:
	_drop_to_base_state()

func _on_ball_received() -> void:
	pass

func _on_ball_lost() -> void:
	pass
