class_name TeammateChaseState
extends TeammateState

func enter() -> void:
	ball_control.ball_received.connect(_on_ball_received)

func exit() -> void:
	if ball_control.ball_received.is_connected(_on_ball_received):
		ball_control.ball_received.disconnect(_on_ball_received)

func process_physics(delta: float) -> void:
	if not _is_match_playing():
		transition_requested.emit(self, &"AIIdleState")
		return
	if is_teammate_carrying_ball():
		transition_requested.emit(self, &"AIDribbleState")
		return
	if not is_ball_free():
		if is_player_team_carrying_ball():
			transition_requested.emit(self, &"AISupportRunState")
		else:
			transition_requested.emit(self, &"AIIdleState")
		return
	var direction: Vector2 = get_ball_direction()
	movement.apply_movement(direction, delta)

func _on_ball_received() -> void:
	transition_requested.emit(self, &"AIDribbleState")
