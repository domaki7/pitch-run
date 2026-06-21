class_name TeammateState
extends State

var teammate: CharacterBody2D = null
var movement: MovementComponent = null
var stamina: StaminaComponent = null
var ball_control: BallControlComponent = null
var kick: KickComponent = null
var tackle_hitbox: TackleHitboxComponent = null
var tackle_hurtbox: TackleHurtboxComponent = null

func _ready() -> void:
	await owner.ready
	teammate = owner as CharacterBody2D
	movement = teammate.movement_component
	stamina = teammate.stamina_component
	ball_control = teammate.ball_control_component
	kick = teammate.kick_component
	tackle_hitbox = teammate.tackle_hitbox_component
	tackle_hurtbox = teammate.tackle_hurtbox_component

func get_ball() -> Ball:
	return GameManager.current_ball as Ball

func get_ball_position() -> Vector2:
	var ball: Ball = get_ball()
	if ball == null:
		return Vector2.ZERO
	return ball.global_position

func get_ball_distance() -> float:
	var ball: Ball = get_ball()
	if ball == null:
		return INF
	return teammate.global_position.distance_to(ball.global_position)

func get_ball_direction() -> Vector2:
	var ball: Ball = get_ball()
	if ball == null:
		return Vector2.ZERO
	return (ball.global_position - teammate.global_position).normalized()

func get_player_position() -> Vector2:
	var player: CharacterBody2D = GameManager.current_player
	if player == null:
		return Vector2.ZERO
	return player.global_position

func get_player_distance() -> float:
	var player: CharacterBody2D = GameManager.current_player
	if player == null:
		return INF
	return teammate.global_position.distance_to(player.global_position)

func get_nearest_opponent() -> CharacterBody2D:
	var nearest: CharacterBody2D = null
	var nearest_dist: float = INF
	for opp in GameManager.opponents:
		var dist: float = teammate.global_position.distance_to(opp.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = opp
	return nearest

func get_formation_position() -> Vector2:
	var player_pos: Vector2 = get_player_position()
	var goal_pos: Vector2 = get_target_goal_position()
	var to_goal: Vector2 = (goal_pos - player_pos).normalized()
	var perp: Vector2 = Vector2(to_goal.y, -to_goal.x)
	return player_pos + to_goal * 150.0 + perp * 100.0

func get_target_goal_position() -> Vector2:
	return Vector2(1600.0, 450.0)

func get_home_position() -> Vector2:
	return teammate.start_position

func get_ball_carrier() -> CharacterBody2D:
	var ball: Ball = get_ball()
	if ball and ball.current_state == Ball.BallState.POSSESSED:
		return ball.possessor
	return null

func is_ball_free() -> bool:
	var ball: Ball = get_ball()
	return ball != null and ball.current_state == Ball.BallState.FREE

func is_teammate_carrying_ball() -> bool:
	return ball_control.has_ball

func is_player_team_carrying_ball() -> bool:
	var carrier: CharacterBody2D = get_ball_carrier()
	return GameManager.is_player_team_entity(carrier) if carrier else false

func _is_match_playing() -> bool:
	return GameManager.current_state == GameManager.MatchState.PLAYING
