class_name KickComponent
extends Node

@export_group("Kick")
@export var pass_force: float = 300.0
@export var shot_force: float = 500.0

func kick_toward(ball: RigidBody2D, target_position: Vector2, force: float) -> void:
	var direction: Vector2 = (target_position - ball.global_position).normalized()
	ball.apply_central_impulse(direction * force)

func pass_ball(ball: RigidBody2D, target_position: Vector2) -> void:
	kick_toward(ball, target_position, pass_force)

func shoot(ball: RigidBody2D, target_position: Vector2) -> void:
	kick_toward(ball, target_position, shot_force)
