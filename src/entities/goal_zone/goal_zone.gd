class_name GoalZone
extends Area2D

signal ball_entered_goal

@export var team: int = 1

var _has_scored_this_play: bool = false

func _ready() -> void:
	add_to_group(&"goal_zones")
	body_entered.connect(_on_body_entered)
	var net: Sprite2D = $NetArea as Sprite2D
	net.position.x = -20.0 if team == 1 else 20.0

func reset() -> void:
	_has_scored_this_play = false

func _on_body_entered(body: Node2D) -> void:
	if _has_scored_this_play:
		return
	if not body is Ball:
		return
	_has_scored_this_play = true
	ball_entered_goal.emit()
	var scoring_team: int = 2 if team == 1 else 1
	EventBus.goal_scored.emit(scoring_team, team)
