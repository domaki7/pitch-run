extends Node

enum MatchState { KICKOFF, PLAYING, GOAL_SCORED, MATCH_OVER }

const GOALS_TO_WIN: int = 3
const GOAL_CELEBRATION_DELAY: float = 1.5
const KICKOFF_DELAY: float = 0.5

var current_state: MatchState = MatchState.PLAYING
var current_player: CharacterBody2D = null
var current_ball: RigidBody2D = null
var is_debug_gui_open: bool = false
var home_score: int = 0
var away_score: int = 0

var _player_start_position: Vector2 = Vector2.ZERO
var _ball_start_position: Vector2 = Vector2.ZERO
var _scored_on_team: int = 0

func _ready() -> void:
	EventBus.goal_scored.connect(_on_goal_scored)

func _unhandled_input(event: InputEvent) -> void:
	if current_state == MatchState.MATCH_OVER and event.is_pressed():
		restart_match()

func register_player(player: CharacterBody2D) -> void:
	current_player = player
	_player_start_position = player.global_position

func register_ball(ball: RigidBody2D) -> void:
	current_ball = ball
	_ball_start_position = ball.global_position

func is_input_disabled() -> bool:
	return is_debug_gui_open or current_state != MatchState.PLAYING

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
	_reset_positions(possession_team)
	var timer: SceneTreeTimer = get_tree().create_timer(KICKOFF_DELAY)
	timer.timeout.connect(_on_kickoff_ready)

func _on_kickoff_ready() -> void:
	current_state = MatchState.PLAYING

func _reset_positions(_possession_team: int) -> void:
	if current_player:
		(current_player as Player).reset_for_kickoff(_player_start_position)
	if current_ball:
		(current_ball as Ball).reset_to_position(_ball_start_position)
	get_tree().call_group(&"goal_zones", &"reset")

func _end_match(winning_team: int) -> void:
	current_state = MatchState.MATCH_OVER
	EventBus.match_ended.emit(winning_team, home_score, away_score)
