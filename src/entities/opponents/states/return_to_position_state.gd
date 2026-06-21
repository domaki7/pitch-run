class_name OpponentReturnToPositionState
extends OpponentState

@export_group("Return")
@export var arrival_threshold: float = 20.0
@export var interrupt_chase_distance: float = 200.0

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
	if is_ball_free() and get_ball_distance() < interrupt_chase_distance:
		transition_requested.emit(self, &"ChaseState")
		return
	if is_player_team_carrying_ball() and get_player_distance() < interrupt_chase_distance:
		transition_requested.emit(self, &"ChaseState")
		return
	var home: Vector2 = get_home_position()
	var direction: Vector2 = (home - opponent.global_position).normalized()
	movement.apply_movement(direction, delta)
	if opponent.global_position.distance_to(home) <= arrival_threshold:
		transition_requested.emit(self, &"IdleState")

func _on_ball_received() -> void:
	transition_requested.emit(self, &"DribbleState")
