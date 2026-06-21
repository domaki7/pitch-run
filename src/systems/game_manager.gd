extends Node

enum MatchState { KICKOFF, PLAYING, GOAL_SCORED, MATCH_OVER }

const GOALS_TO_WIN: int = 3
const GOAL_CELEBRATION_DELAY: float = 1.5
const KICKOFF_DELAY: float = 0.5

var current_state: MatchState = MatchState.PLAYING
var current_player: CharacterBody2D = null
var current_ball: RigidBody2D = null
var current_opponent: CharacterBody2D = null
var is_debug_gui_open: bool = false
var home_score: int = 0
var away_score: int = 0
var teammates: Array[CharacterBody2D] = []
var opponents: Array[CharacterBody2D] = []

var _original_player: CharacterBody2D = null
var _player_start_position: Vector2 = Vector2.ZERO
var _ball_start_position: Vector2 = Vector2.ZERO
var _teammate_start_positions: Dictionary = {}
var _opponent_start_positions: Dictionary = {}
var _scored_on_team: int = 0

func _ready() -> void:
	EventBus.goal_scored.connect(_on_goal_scored)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"switch_player"):
		switch_to_nearest_teammate()

func register_player(player: CharacterBody2D) -> void:
	current_player = player
	_original_player = player
	_player_start_position = player.global_position

func register_ball(ball: RigidBody2D) -> void:
	current_ball = ball
	_ball_start_position = ball.global_position

func register_teammate(teammate: CharacterBody2D) -> void:
	if teammate not in teammates:
		teammates.append(teammate)
	_teammate_start_positions[teammate.get_instance_id()] = teammate.global_position

func register_opponent(opponent: CharacterBody2D) -> void:
	if current_opponent == null:
		current_opponent = opponent
	if opponent not in opponents:
		opponents.append(opponent)
	_opponent_start_positions[opponent.get_instance_id()] = opponent.global_position

func get_player_team_entities() -> Array[CharacterBody2D]:
	var entities: Array[CharacterBody2D] = []
	if current_player:
		entities.append(current_player)
	entities.append_array(teammates)
	return entities

func is_player_team_entity(entity: CharacterBody2D) -> bool:
	return entity == current_player or entity in teammates

func is_input_disabled() -> bool:
	return is_debug_gui_open or current_state != MatchState.PLAYING

func switch_to_nearest_teammate() -> void:
	if current_state != MatchState.PLAYING:
		return
	if teammates.is_empty():
		return
	var nearest: CharacterBody2D = null
	var nearest_dist: float = INF
	for t in teammates:
		var dist: float = current_player.global_position.distance_to(t.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = t
	if nearest == null:
		return
	var old_player: CharacterBody2D = current_player
	teammates.erase(nearest)
	teammates.append(old_player)
	var camera: Camera2D = old_player.get_node("Camera2D") as Camera2D
	if camera:
		old_player.remove_child(camera)
		nearest.add_child(camera)
		camera.position = Vector2.ZERO
	current_player = nearest
	old_player.set_player_controlled(false)
	nearest.set_player_controlled(true)

func _restore_original_player() -> void:
	if current_player == _original_player:
		return
	if _original_player in teammates:
		teammates.erase(_original_player)
		teammates.append(current_player)
	var camera: Camera2D = current_player.get_node("Camera2D") as Camera2D
	if camera:
		current_player.remove_child(camera)
		_original_player.add_child(camera)
		camera.position = Vector2.ZERO
	current_player.set_player_controlled(false)
	current_player = _original_player
	_original_player.set_player_controlled(true)

func start_match() -> void:
	home_score = 0
	away_score = 0
	_begin_kickoff(1)

func restart_match() -> void:
	start_match()

func _on_goal_scored(scoring_team: int, scored_on_team: int) -> void:
	if current_state != MatchState.PLAYING:
		return
	current_state = MatchState.GOAL_SCORED
	_scored_on_team = scored_on_team
	if scoring_team == 1:
		home_score += 1
	else:
		away_score += 1
	var timer: SceneTreeTimer = get_tree().create_timer(GOAL_CELEBRATION_DELAY)
	timer.timeout.connect(_on_goal_celebration_finished)

func _on_goal_celebration_finished() -> void:
	if home_score >= GOALS_TO_WIN:
		_end_match(1)
	elif away_score >= GOALS_TO_WIN:
		_end_match(2)
	else:
		_begin_kickoff(_scored_on_team)

func _begin_kickoff(possession_team: int) -> void:
	current_state = MatchState.KICKOFF
	EventBus.kickoff_started.emit()
	_restore_original_player()
	_reset_positions(possession_team)
	var timer: SceneTreeTimer = get_tree().create_timer(KICKOFF_DELAY)
	timer.timeout.connect(_on_kickoff_ready)

func _on_kickoff_ready() -> void:
	current_state = MatchState.PLAYING

func _reset_positions(_possession_team: int) -> void:
	if current_player:
		current_player.reset_for_kickoff(_player_start_position)
	for t in teammates:
		var start_pos: Vector2 = _teammate_start_positions.get(t.get_instance_id(), t.global_position)
		t.reset_for_kickoff(start_pos)
	for o in opponents:
		var start_pos: Vector2 = _opponent_start_positions.get(o.get_instance_id(), o.global_position)
		o.reset_for_kickoff(start_pos)
	if current_ball:
		(current_ball as Ball).reset_to_position(_ball_start_position)
	get_tree().call_group(&"goal_zones", &"reset")

func _end_match(winning_team: int) -> void:
	current_state = MatchState.MATCH_OVER
	EventBus.match_ended.emit(winning_team, home_score, away_score)
