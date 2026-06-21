extends Node

enum RunState { NOT_IN_RUN, PRE_MATCH, IN_MATCH, POST_MATCH, RUN_ENDED }

const BASE_STAT_MULTIPLIER: float = 1.0
const STAT_MULTIPLIER_PER_MATCH: float = 0.1
const TEAM_SIZE_TABLE: Array[int] = [1, 1, 2, 2, 3, 3, 4, 4, 5]

@export_group("Run Settings")
@export var default_max_lives: int = 1

var current_state: RunState = RunState.NOT_IN_RUN
var run_data: RunData = null


func _ready() -> void:
	EventBus.match_ended.connect(_on_match_ended)
	start_run.call_deferred()


func start_run(max_lives: int = -1) -> void:
	var lives: int = max_lives if max_lives >= 0 else default_max_lives
	run_data = RunData.new()
	run_data.reset(lives)
	current_state = RunState.PRE_MATCH
	EventBus.run_started.emit(run_data)
	_start_next_match()


func advance_to_next_match() -> void:
	run_data.increment_match()
	current_state = RunState.PRE_MATCH
	EventBus.pre_match_started.emit(run_data.match_number)
	_start_next_match()


func retry_match() -> void:
	current_state = RunState.PRE_MATCH
	_start_next_match()


func end_run(reason: String) -> void:
	current_state = RunState.RUN_ENDED
	EventBus.run_ended.emit(run_data, reason)


func is_run_active() -> bool:
	return current_state != RunState.NOT_IN_RUN and current_state != RunState.RUN_ENDED


func get_opponent_stat_multiplier() -> float:
	if run_data == null:
		return 1.0
	return BASE_STAT_MULTIPLIER + (run_data.match_number - 1) * STAT_MULTIPLIER_PER_MATCH


func get_team_size() -> int:
	if run_data == null:
		return 1
	var index: int = clampi(run_data.difficulty_level - 1, 0, TEAM_SIZE_TABLE.size() - 1)
	return TEAM_SIZE_TABLE[index]


func _start_next_match() -> void:
	current_state = RunState.IN_MATCH
	GameManager.start_match()


func _on_match_ended(winning_team: int, home_score: int, away_score: int) -> void:
	if current_state != RunState.IN_MATCH:
		return

	var is_win: bool = winning_team == 1
	run_data.record_match_result(is_win, home_score, away_score)

	if not is_win:
		run_data.lives_remaining -= 1

	current_state = RunState.POST_MATCH
	EventBus.match_completed.emit(run_data.match_number, is_win, run_data)
