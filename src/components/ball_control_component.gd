class_name BallControlComponent
extends Node

signal ball_received
signal ball_lost

@export_group("Dribble")
@export var dribble_offset: float = 20.0
@export var dribble_lerp_speed: float = 15.0

var has_ball: bool = false
var _body: CharacterBody2D = null
var _ball: RigidBody2D = null
var _facing_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	_body = get_parent() as CharacterBody2D

func _physics_process(delta: float) -> void:
	if has_ball and _ball:
		var target_pos: Vector2 = _body.global_position + _facing_direction * dribble_offset
		_ball.global_position = _ball.global_position.lerp(target_pos, 1.0 - exp(-dribble_lerp_speed * delta))

func receive_ball(ball: RigidBody2D) -> void:
	_ball = ball
	has_ball = true
	_ball.freeze = true
	ball_received.emit()

func release_ball() -> RigidBody2D:
	if not has_ball or not _ball:
		return null
	var ball: RigidBody2D = _ball
	ball.freeze = false
	has_ball = false
	_ball = null
	ball_lost.emit()
	return ball

func update_facing(direction: Vector2) -> void:
	if direction.length_squared() > 0.0:
		_facing_direction = direction.normalized()
