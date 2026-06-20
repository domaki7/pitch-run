class_name MovementComponent
extends Node

@export_group("Movement")
@export var speed: float = 200.0
@export var acceleration: float = 10.0
@export var friction: float = 8.0
@export var sprint_multiplier: float = 1.5

var _body: CharacterBody2D = null

func _ready() -> void:
	_body = get_parent() as CharacterBody2D

func apply_movement(direction: Vector2, delta: float, is_sprinting: bool = false) -> void:
	var target_speed: float = speed * (sprint_multiplier if is_sprinting else 1.0)
	if direction.length_squared() > 0.0:
		var target_velocity: Vector2 = direction.normalized() * target_speed
		_body.velocity = _body.velocity.lerp(target_velocity, 1.0 - exp(-acceleration * delta))
	else:
		_body.velocity = _body.velocity.lerp(Vector2.ZERO, 1.0 - exp(-friction * delta))
	_body.move_and_slide()
