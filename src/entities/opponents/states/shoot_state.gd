class_name OpponentShootState
extends OpponentState

func enter() -> void:
	if not ball_control.has_ball:
		transition_requested.emit(self, &"ChaseState")
		return
	var ball: RigidBody2D = ball_control.release_ball()
	if ball:
		kick.shoot(ball, get_target_goal_position())
	transition_requested.emit(self, &"ChaseState")

func process_physics(delta: float) -> void:
	movement.apply_movement(Vector2.ZERO, delta)
