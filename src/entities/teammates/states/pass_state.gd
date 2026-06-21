class_name TeammatePassState
extends TeammateState

func enter() -> void:
	if not ball_control.has_ball:
		transition_requested.emit(self, &"AISupportRunState")
		return
	var ball: RigidBody2D = ball_control.release_ball()
	if ball:
		kick.pass_ball(ball, get_player_position())
	transition_requested.emit(self, &"AISupportRunState")

func process_physics(delta: float) -> void:
	movement.apply_movement(Vector2.ZERO, delta)
