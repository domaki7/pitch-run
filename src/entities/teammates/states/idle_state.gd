class_name TeammateIdleState
extends TeammateState

@export_group("Idle")
@export var chase_range: float = 300.0

func enter() -> void:
	ball_control.ball_received.connect(_on_ball_received)

func exit() -> void:
	if ball_control.ball_received.is_connected(_on_ball_received):
		ball_control.ball_received.disconnect(_on_ball_received)

func process_physics(delta: float) -> void:
	if not _is_match_playing():
		movement.apply_movement(Vector2.ZERO, delta)
		return
	if is_teammate_carrying_ball():
		transition_requested.emit(self, &"AIDribbleState")
		return
	if is_player_team_carrying_ball():
		transition_requested.emit(self, &"AISupportRunState")
		return
	if is_ball_free() and get_ball_distance() < chase_range:
		transition_requested.emit(self, &"AIChaseState")
		return
	var home: Vector2 = get_formation_position()
	var dist: float = teammate.global_position.distance_to(home)
	if dist > 10.0:
		var direction: Vector2 = (home - teammate.global_position).normalized()
		movement.apply_movement(direction, delta)
	else:
		movement.apply_movement(Vector2.ZERO, delta)

func _on_ball_received() -> void:
	transition_requested.emit(self, &"AIDribbleState")
