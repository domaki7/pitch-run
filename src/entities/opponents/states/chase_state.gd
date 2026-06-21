class_name OpponentChaseState
extends OpponentState

@export_group("Chase")
@export var tackle_range: float = 50.0

func enter() -> void:
	ball_control.ball_received.connect(_on_ball_received)

func exit() -> void:
	if ball_control.ball_received.is_connected(_on_ball_received):
		ball_control.ball_received.disconnect(_on_ball_received)

func process_physics(delta: float) -> void:
	if not _is_match_playing():
		transition_requested.emit(self, &"IdleState")
		return
	if is_opponent_carrying_ball():
		transition_requested.emit(self, &"DribbleState")
		return
	if is_player_team_carrying_ball():
		var dir: Vector2 = get_player_direction()
		movement.apply_movement(dir, delta)
		if get_player_distance() <= tackle_range and stamina.current_stamina >= stamina.tackle_cost:
			transition_requested.emit(self, &"TackleState")
			return
	elif is_ball_free():
		var dir: Vector2 = get_ball_direction()
		movement.apply_movement(dir, delta)
	else:
		var dir: Vector2 = get_ball_direction()
		movement.apply_movement(dir, delta)

func _on_ball_received() -> void:
	transition_requested.emit(self, &"DribbleState")
