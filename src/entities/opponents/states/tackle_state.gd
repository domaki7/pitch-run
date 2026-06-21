class_name OpponentTackleState
extends OpponentState

@export_group("Lunge")
@export var lunge_distance: float = 100.0
@export var lunge_duration: float = 0.2
@export var cooldown_duration: float = 0.9

@export_group("Ball Pop")
@export var ball_pop_force: float = 150.0
@export var ball_pop_bias: float = 0.6

var _lunge_direction: Vector2 = Vector2.ZERO
var _lunge_speed: float = 0.0
var _lunge_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _is_lunging: bool = false
var _is_cooling_down: bool = false
var _hit_landed: bool = false

func enter() -> void:
	if not stamina.use_stamina(stamina.tackle_cost):
		transition_requested.emit(self, &"IdleState")
		return

	_lunge_direction = get_player_direction()
	if _lunge_direction.length_squared() == 0.0:
		_lunge_direction = movement.last_facing_direction

	_lunge_speed = lunge_distance / lunge_duration
	_lunge_timer = lunge_duration
	_cooldown_timer = 0.0
	_is_lunging = true
	_is_cooling_down = false
	_hit_landed = false

	tackle_hitbox.activate(_lunge_direction)
	tackle_hurtbox.set_invulnerable(true)
	tackle_hitbox.tackle_hit.connect(_on_tackle_hit)
	ball_control.ball_received.connect(_on_ball_received_during_tackle)

func exit() -> void:
	tackle_hitbox.deactivate()
	tackle_hurtbox.set_invulnerable(false)
	if tackle_hitbox.tackle_hit.is_connected(_on_tackle_hit):
		tackle_hitbox.tackle_hit.disconnect(_on_tackle_hit)
	if ball_control.ball_received.is_connected(_on_ball_received_during_tackle):
		ball_control.ball_received.disconnect(_on_ball_received_during_tackle)
	_is_lunging = false
	_is_cooling_down = false

func process_physics(delta: float) -> void:
	if _is_lunging:
		_lunge_timer -= delta
		if _lunge_timer <= 0.0:
			_end_lunge()
			return
		opponent.velocity = _lunge_direction * _lunge_speed
		opponent.move_and_slide()
	elif _is_cooling_down:
		_cooldown_timer -= delta
		movement.apply_movement(Vector2.ZERO, delta)
		if _cooldown_timer <= 0.0:
			if ball_control.has_ball:
				transition_requested.emit(self, &"DribbleState")
			else:
				transition_requested.emit(self, &"ChaseState")

func _end_lunge() -> void:
	_is_lunging = false
	tackle_hitbox.deactivate()
	tackle_hurtbox.set_invulnerable(false)
	opponent.velocity = Vector2.ZERO
	_is_cooling_down = true
	_cooldown_timer = cooldown_duration

func _on_tackle_hit(hurtbox: Area2D) -> void:
	if _hit_landed:
		return
	_hit_landed = true

	var victim: Node2D = hurtbox.get_parent() as Node2D
	if victim and "ball_control_component" in victim:
		var victim_bc: BallControlComponent = victim.ball_control_component
		if victim_bc and victim_bc.has_ball:
			var ball: RigidBody2D = victim_bc.release_ball()
			if ball:
				var to_attacker: Vector2 = (opponent.global_position - ball.global_position).normalized()
				var pop_dir: Vector2 = (_lunge_direction * (1.0 - ball_pop_bias) + to_attacker * ball_pop_bias).normalized()
				ball.apply_central_impulse(pop_dir * ball_pop_force)

	if hurtbox.has_method(&"notify_tackled"):
		hurtbox.notify_tackled({"attacker": opponent, "direction": _lunge_direction})

	_is_lunging = false
	tackle_hitbox.deactivate()
	tackle_hurtbox.set_invulnerable(false)
	opponent.velocity = Vector2.ZERO
	_is_cooling_down = true
	_cooldown_timer = cooldown_duration

func _on_ball_received_during_tackle() -> void:
	pass
