class_name TeammateSupportRunState
extends TeammateState

@export_group("Support")
@export var support_distance: float = 150.0
@export var spread_distance: float = 100.0
@export var arrival_threshold: float = 20.0

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
	if is_ball_free():
		transition_requested.emit(self, &"AIChaseState")
		return
	if not is_player_team_carrying_ball():
		transition_requested.emit(self, &"AIIdleState")
		return
	var target: Vector2 = _get_support_position()
	var dist: float = teammate.global_position.distance_to(target)
	if dist > arrival_threshold:
		var direction: Vector2 = (target - teammate.global_position).normalized()
		movement.apply_movement(direction, delta)
	else:
		movement.apply_movement(Vector2.ZERO, delta)

func _get_support_position() -> Vector2:
	var player_pos: Vector2 = get_player_position()
	var goal_pos: Vector2 = get_target_goal_position()
	var to_goal: Vector2 = (goal_pos - player_pos).normalized()
	var perp: Vector2 = Vector2(to_goal.y, -to_goal.x)
	return player_pos + to_goal * support_distance + perp * spread_distance

func _on_ball_received() -> void:
	transition_requested.emit(self, &"AIDribbleState")
