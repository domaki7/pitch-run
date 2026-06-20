class_name Player
extends CharacterBody2D

var state_machine: StateMachine = null
var movement_component: MovementComponent = null
var stamina_component: StaminaComponent = null
var ball_control_component: BallControlComponent = null
var kick_component: KickComponent = null

func _ready() -> void:
	state_machine = $StateMachine as StateMachine
	movement_component = $MovementComponent as MovementComponent
	stamina_component = $StaminaComponent as StaminaComponent
	ball_control_component = $BallControlComponent as BallControlComponent
	kick_component = $KickComponent as KickComponent

	var ball_detection: Area2D = $BallDetectionArea as Area2D
	ball_detection.body_entered.connect(_on_ball_detection_area_body_entered)

	GameManager.register_player(self)
	_start_state_machine.call_deferred()

func _start_state_machine() -> void:
	state_machine.transition_to(&"IdleState")

func _on_ball_detection_area_body_entered(body: Node2D) -> void:
	if ball_control_component.has_ball:
		return
	var ball: Ball = body as Ball
	if ball == null:
		return
	if ball.current_state != Ball.BallState.FREE:
		return
	ball_control_component.receive_ball(ball)
