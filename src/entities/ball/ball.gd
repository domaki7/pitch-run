class_name Ball
extends RigidBody2D

signal state_changed(new_state: BallState)

enum BallState { FREE, POSSESSED, IN_FLIGHT }

@export_group("Physics")
@export var ball_linear_damp: float = 3.0
@export var ball_angular_damp: float = 1.0
@export var ball_bounce: float = 0.3
@export var ball_friction: float = 0.8

var current_state: BallState = BallState.FREE
var possessor: CharacterBody2D = null

func _ready() -> void:
	gravity_scale = 0.0
	linear_damp = ball_linear_damp
	angular_damp = ball_angular_damp
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY

	var mat: PhysicsMaterial = PhysicsMaterial.new()
	mat.bounce = ball_bounce
	mat.friction = ball_friction
	physics_material_override = mat

	GameManager.register_ball(self)

func set_possessed(by: CharacterBody2D) -> void:
	possessor = by
	current_state = BallState.POSSESSED
	state_changed.emit(current_state)

func set_free() -> void:
	possessor = null
	current_state = BallState.FREE
	state_changed.emit(current_state)

func set_in_flight() -> void:
	possessor = null
	current_state = BallState.IN_FLIGHT
	state_changed.emit(current_state)
