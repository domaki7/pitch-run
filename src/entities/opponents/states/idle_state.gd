class_name OpponentIdleState
extends OpponentState

func enter() -> void:
	pass

func process_physics(delta: float) -> void:
	movement.apply_movement(Vector2.ZERO, delta)
	if not _is_match_playing():
		return
	if is_opponent_carrying_ball():
		transition_requested.emit(self, &"DribbleState")
		return
	if is_ball_free() or is_player_carrying_ball():
		transition_requested.emit(self, &"ChaseState")
		return
