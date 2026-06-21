extends CanvasLayer

var _home_score_label: Label = null
var _away_score_label: Label = null
var _match_end_overlay: ColorRect = null
var _result_label: Label = null
var _final_score_label: Label = null
var _restart_label: Label = null
var _match_number_label: Label = null
var _lives_label: Label = null
var _last_winning_team: int = 0


func _ready() -> void:
	_build_score_display()
	_build_run_info_display()
	_build_match_end_overlay()
	EventBus.goal_scored.connect(_on_goal_scored)
	EventBus.match_ended.connect(_on_match_ended)
	EventBus.kickoff_started.connect(_on_kickoff_started)
	EventBus.run_started.connect(_on_run_started)


func _unhandled_input(event: InputEvent) -> void:
	if GameManager.current_state != GameManager.MatchState.MATCH_OVER:
		return
	if not event.is_pressed():
		return

	if _last_winning_team == 1:
		RunManager.advance_to_next_match()
	elif RunManager.run_data and RunManager.run_data.lives_remaining > 0:
		RunManager.retry_match()
	else:
		RunManager.end_run("permadeath")
		RunManager.start_run()


func _build_score_display() -> void:
	var container: HBoxContainer = HBoxContainer.new()
	container.name = "ScoreDisplay"
	container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	container.position = Vector2(-60, 10)
	container.size = Vector2(120, 40)

	var theme_large: Theme = Theme.new()
	theme_large.set_font_size("font_size", "Label", 28)
	container.theme = theme_large

	_home_score_label = Label.new()
	_home_score_label.text = "0"
	_home_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_home_score_label.custom_minimum_size = Vector2(40, 0)
	container.add_child(_home_score_label)

	var separator: Label = Label.new()
	separator.text = " - "
	separator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(separator)

	_away_score_label = Label.new()
	_away_score_label.text = "0"
	_away_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_away_score_label.custom_minimum_size = Vector2(40, 0)
	container.add_child(_away_score_label)

	add_child(container)


func _build_run_info_display() -> void:
	var container: VBoxContainer = VBoxContainer.new()
	container.name = "RunInfo"
	container.position = Vector2(16, 10)

	var theme_small: Theme = Theme.new()
	theme_small.set_font_size("font_size", "Label", 18)
	container.theme = theme_small

	_match_number_label = Label.new()
	_match_number_label.text = "Match 1"
	container.add_child(_match_number_label)

	_lives_label = Label.new()
	_lives_label.text = ""
	container.add_child(_lives_label)

	add_child(container)


func _build_match_end_overlay() -> void:
	_match_end_overlay = ColorRect.new()
	_match_end_overlay.name = "MatchEndOverlay"
	_match_end_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_match_end_overlay.color = Color(0, 0, 0, 0.6)
	_match_end_overlay.visible = false
	_match_end_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_match_end_overlay.add_child(center)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)

	_result_label = Label.new()
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var result_theme: Theme = Theme.new()
	result_theme.set_font_size("font_size", "Label", 48)
	_result_label.theme = result_theme
	vbox.add_child(_result_label)

	_final_score_label = Label.new()
	_final_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var score_theme: Theme = Theme.new()
	score_theme.set_font_size("font_size", "Label", 32)
	_final_score_label.theme = score_theme
	vbox.add_child(_final_score_label)

	_restart_label = Label.new()
	_restart_label.text = "Press any key to continue"
	_restart_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var restart_theme: Theme = Theme.new()
	restart_theme.set_font_size("font_size", "Label", 18)
	_restart_label.theme = restart_theme
	vbox.add_child(_restart_label)

	add_child(_match_end_overlay)


func _on_goal_scored(_scoring_team: int, _scored_on_team: int) -> void:
	_home_score_label.text = str(GameManager.home_score)
	_away_score_label.text = str(GameManager.away_score)


func _on_match_ended(winning_team: int, home_score: int, away_score: int) -> void:
	_last_winning_team = winning_team
	_match_end_overlay.visible = true
	_final_score_label.text = str(home_score) + " - " + str(away_score)

	if winning_team == 1:
		_result_label.text = "Match Won!"
		_restart_label.text = "Press any key to continue"
	elif RunManager.run_data and RunManager.run_data.lives_remaining > 0:
		_result_label.text = "Match Lost!"
		_restart_label.text = str(RunManager.run_data.lives_remaining) + " lives remaining. Press any key to retry"
	else:
		_result_label.text = "Run Over!"
		var match_num: int = RunManager.run_data.match_number if RunManager.run_data else 1
		_restart_label.text = "Reached Match " + str(match_num) + ". Press any key to restart"


func _on_kickoff_started() -> void:
	_match_end_overlay.visible = false
	_home_score_label.text = str(GameManager.home_score)
	_away_score_label.text = str(GameManager.away_score)
	_update_run_info()


func _on_run_started(_run_data: RunData) -> void:
	_update_run_info()


func _update_run_info() -> void:
	if RunManager.run_data:
		_match_number_label.text = "Match " + str(RunManager.run_data.match_number)
		if RunManager.run_data.max_lives > 0:
			_lives_label.text = "Lives: " + str(RunManager.run_data.lives_remaining)
			_lives_label.visible = true
		else:
			_lives_label.visible = false
	else:
		_match_number_label.text = "Match 1"
		_lives_label.visible = false
