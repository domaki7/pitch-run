extends CanvasLayer

var _home_score_label: Label = null
var _away_score_label: Label = null
var _match_end_overlay: ColorRect = null
var _result_label: Label = null
var _final_score_label: Label = null

func _ready() -> void:
	_build_score_display()
	_build_match_end_overlay()
	EventBus.goal_scored.connect(_on_goal_scored)
	EventBus.match_ended.connect(_on_match_ended)
	EventBus.kickoff_started.connect(_on_kickoff_started)

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

	var restart_label: Label = Label.new()
	restart_label.text = "Press any key to restart"
	restart_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var restart_theme: Theme = Theme.new()
	restart_theme.set_font_size("font_size", "Label", 18)
	restart_label.theme = restart_theme
	vbox.add_child(restart_label)

	add_child(_match_end_overlay)

func _on_goal_scored(_scoring_team: int, _scored_on_team: int) -> void:
	_home_score_label.text = str(GameManager.home_score)
	_away_score_label.text = str(GameManager.away_score)

func _on_match_ended(winning_team: int, home_score: int, away_score: int) -> void:
	_match_end_overlay.visible = true
	_result_label.text = "You Win!" if winning_team == 1 else "You Lose!"
	_final_score_label.text = str(home_score) + " - " + str(away_score)

func _on_kickoff_started() -> void:
	_match_end_overlay.visible = false
	_home_score_label.text = str(GameManager.home_score)
	_away_score_label.text = str(GameManager.away_score)
