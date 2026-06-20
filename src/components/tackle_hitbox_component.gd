class_name TackleHitboxComponent
extends Area2D

signal tackle_hit(hurtbox: Area2D)

@export_group("Hitbox")
@export var hitbox_offset: float = 20.0
@export var hitbox_width: float = 24.0
@export var hitbox_height: float = 16.0

var debug_draw: bool = false
var _collision_shape: CollisionShape2D = null
var _capsule: CapsuleShape2D = null

func _ready() -> void:
	_collision_shape = $CollisionShape2D as CollisionShape2D
	_capsule = _collision_shape.shape as CapsuleShape2D
	area_entered.connect(_on_area_entered)
	deactivate()

func activate(direction: Vector2) -> void:
	_capsule.radius = hitbox_height / 2.0
	_capsule.height = hitbox_width
	_collision_shape.position = direction * hitbox_offset
	_collision_shape.rotation = direction.angle() - PI / 2.0
	_collision_shape.disabled = false
	monitoring = true
	if debug_draw:
		queue_redraw()

func deactivate() -> void:
	_collision_shape.disabled = true
	monitoring = false
	if debug_draw:
		queue_redraw()

func _on_area_entered(area: Area2D) -> void:
	tackle_hit.emit(area)

func _draw() -> void:
	if not debug_draw:
		return
	var pos: Vector2 = _collision_shape.position
	var rot: float = _collision_shape.rotation
	var half_height: float = _capsule.height / 2.0
	var radius: float = _capsule.radius
	var axis: Vector2 = Vector2.from_angle(rot + PI / 2.0)
	var cap_top: Vector2 = pos + axis * (half_height - radius)
	var cap_bot: Vector2 = pos - axis * (half_height - radius)
	var color: Color = Color(1.0, 0.0, 0.0, 0.4) if monitoring else Color(1.0, 0.0, 0.0, 0.15)
	draw_circle(cap_top, radius, color)
	draw_circle(cap_bot, radius, color)
	var perp: Vector2 = Vector2.from_angle(rot)
	draw_line(cap_top + perp * radius, cap_bot + perp * radius, color, 2.0)
	draw_line(cap_top - perp * radius, cap_bot - perp * radius, color, 2.0)

func _physics_process(_delta: float) -> void:
	if debug_draw and monitoring:
		queue_redraw()
