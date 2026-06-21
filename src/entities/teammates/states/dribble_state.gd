class_name TeammateDribbleState
extends TeammateState

@export_group("Dribble")
@export var shoot_range: float = 500.0
@export var pass_prefer_distance: float = 300.0
@export var stuck_duration: float = 0.5

var _stuck_timer: float = 0.0

func enter() -> void:
	_stuck_timer = 0.0
	ball_control.ball_lost.connect(_on_ball_lost)

func exit() -> void:
	if ball_control.ball_lost.is_connected(_on_ball_lost):
		ball_control.ball_lost.disconnect(_on_ball_lost)

func process_physics(delta: float) -> void:
	if not _is_match_playing():
		transition_requested.emit(self, &"AIIdleState")
		return
	if not ball_control.has_ball:
		transition_requested.emit(self, &"AIChaseState")
		return
	var goal_pos: Vector2 = get_target_goal_position()
	var dist_to_goal: float = teammate.global_position.distance_to(goal_pos)
	if dist_to_goal <= shoot_range:
		transition_requested.emit(self, &"AIShootState")
		return
	var player_pos: Vector2 = get_player_position()
	var player_dist_to_goal: float = player_pos.distance_to(goal_pos)
	if player_dist_to_goal < dist_to_goal - pass_prefer_distance:
		transition_requested.emit(self, &"AIPassState")
		return
	var direction: Vector2 = (goal_pos - teammate.global_position).normalized()
	movement.apply_movement(direction, delta)
	ball_control.update_facing(direction)
	if teammate.velocity.length_squared() < 100.0:
		_stuck_timer += delta
		if _stuck_timer >= stuck_duration:
			transition_requested.emit(self, &"AIShootState")
			return
	else:
		_stuck_timer = 0.0

func _on_ball_lost() -> void:
	transition_requested.emit(self, &"AIChaseState")
