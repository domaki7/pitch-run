class_name TackleHurtboxComponent
extends Area2D

signal tackled(tackle_data: Dictionary)

@export_group("Hurtbox")
@export var hurtbox_radius: float = 12.0

var debug_draw: bool = false
var _collision_shape: CollisionShape2D = null
var _circle: CircleShape2D = null

func _ready() -> void:
	_collision_shape = $CollisionShape2D as CollisionShape2D
	_circle = _collision_shape.shape as CircleShape2D
	_circle.radius = hurtbox_radius

func set_invulnerable(value: bool) -> void:
	_collision_shape.disabled = value
	if debug_draw:
		queue_redraw()

func notify_tackled(data: Dictionary) -> void:
	tackled.emit(data)

func _draw() -> void:
	if not debug_draw:
		return
	var color: Color = Color(0.0, 0.4, 1.0, 0.3) if not _collision_shape.disabled else Color(0.0, 0.4, 1.0, 0.1)
	draw_circle(Vector2.ZERO, _circle.radius, color)
