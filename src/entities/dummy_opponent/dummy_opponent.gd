class_name DummyOpponent
extends CharacterBody2D

var ball_control_component: BallControlComponent = null

func _ready() -> void:
	ball_control_component = $BallControlComponent as BallControlComponent
	var ball_detection: Area2D = $BallDetectionArea as Area2D
	ball_detection.body_entered.connect(_on_ball_detection_area_body_entered)
	add_to_group("opponents")

func _on_ball_detection_area_body_entered(body: Node2D) -> void:
	if ball_control_component.has_ball:
		return
	var ball: Ball = body as Ball
	if ball == null:
		return
	if ball.current_state != Ball.BallState.FREE:
		return
	ball_control_component.receive_ball(ball)
