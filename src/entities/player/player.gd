class_name Player
extends CharacterBody2D

var state_machine: StateMachine = null
var movement_component: MovementComponent = null
var stamina_component: StaminaComponent = null
var ball_control_component: BallControlComponent = null
var kick_component: KickComponent = null
var tackle_hitbox_component: TackleHitboxComponent = null
var tackle_hurtbox_component: TackleHurtboxComponent = null
var _stamina_bar: ProgressBar = null
var _state_label: Label = null

func _ready() -> void:
	state_machine = $StateMachine as StateMachine
	movement_component = $MovementComponent as MovementComponent
	stamina_component = $StaminaComponent as StaminaComponent
	ball_control_component = $BallControlComponent as BallControlComponent
	kick_component = $KickComponent as KickComponent
	tackle_hitbox_component = $TackleHitboxComponent as TackleHitboxComponent
	tackle_hurtbox_component = $TackleHurtboxComponent as TackleHurtboxComponent
	_stamina_bar = $StaminaBar as ProgressBar
	_state_label = $StateLabel as Label

	var ball_detection: Area2D = $BallDetectionArea as Area2D
	ball_detection.body_entered.connect(_on_ball_detection_area_body_entered)
	stamina_component.stamina_changed.connect(_on_stamina_changed)
	state_machine.transitioned.connect(_on_state_transitioned)

	GameManager.register_player(self)
	_start_state_machine.call_deferred()

func _start_state_machine() -> void:
	state_machine.transition_to(&"IdleState")

func set_state_label_visible(is_visible: bool) -> void:
	_state_label.visible = is_visible

func _on_stamina_changed(current: float, maximum: float) -> void:
	_stamina_bar.max_value = maximum
	_stamina_bar.value = current
	_stamina_bar.visible = current < maximum

func _on_state_transitioned(_old_name: StringName, new_name: StringName) -> void:
	_state_label.text = new_name

func reset_for_kickoff(start_pos: Vector2) -> void:
	if ball_control_component.has_ball:
		ball_control_component.release_ball()
	global_position = start_pos
	velocity = Vector2.ZERO
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
