class_name OpponentState
extends State

var opponent: CharacterBody2D = null
var movement: MovementComponent = null
var stamina: StaminaComponent = null
var ball_control: BallControlComponent = null
var kick: KickComponent = null
var tackle_hitbox: TackleHitboxComponent = null
var tackle_hurtbox: TackleHurtboxComponent = null

func _ready() -> void:
	await owner.ready
	opponent = owner as CharacterBody2D
	movement = opponent.movement_component
	stamina = opponent.stamina_component
	ball_control = opponent.ball_control_component
	kick = opponent.kick_component
	tackle_hitbox = opponent.tackle_hitbox_component
	tackle_hurtbox = opponent.tackle_hurtbox_component

func get_ball() -> Ball:
	return GameManager.current_ball as Ball

func get_nearest_player_team_entity() -> CharacterBody2D:
	var nearest: CharacterBody2D = null
	var nearest_dist: float = INF
	for entity in GameManager.get_player_team_entities():
		var dist: float = opponent.global_position.distance_to(entity.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = entity
	return nearest

func get_player_team_ball_carrier() -> CharacterBody2D:
	var carrier: CharacterBody2D = get_ball_carrier()
	if carrier and GameManager.is_player_team_entity(carrier):
		return carrier
	return null

func get_player_distance() -> float:
	var target: CharacterBody2D = get_player_team_ball_carrier()
	if target == null:
		target = get_nearest_player_team_entity()
	if target == null:
		return INF
	return opponent.global_position.distance_to(target.global_position)

func get_player_direction() -> Vector2:
	var target: CharacterBody2D = get_player_team_ball_carrier()
	if target == null:
		target = get_nearest_player_team_entity()
	if target == null:
		return Vector2.ZERO
	return (target.global_position - opponent.global_position).normalized()

func get_ball_distance() -> float:
	var ball: Ball = get_ball()
	if ball == null:
		return INF
	return opponent.global_position.distance_to(ball.global_position)

func get_ball_direction() -> Vector2:
	var ball: Ball = get_ball()
	if ball == null:
		return Vector2.ZERO
	return (ball.global_position - opponent.global_position).normalized()

func get_ball_carrier() -> CharacterBody2D:
	var ball: Ball = get_ball()
	if ball and ball.current_state == Ball.BallState.POSSESSED:
		return ball.possessor
	return null

func is_ball_free() -> bool:
	var ball: Ball = get_ball()
	return ball != null and ball.current_state == Ball.BallState.FREE

func is_player_team_carrying_ball() -> bool:
	var carrier: CharacterBody2D = get_ball_carrier()
	return GameManager.is_player_team_entity(carrier) if carrier else false

func is_opponent_carrying_ball() -> bool:
	return ball_control.has_ball

func _is_match_playing() -> bool:
	return GameManager.current_state == GameManager.MatchState.PLAYING

func get_target_goal_position() -> Vector2:
	return Vector2(0.0, 450.0)

func get_home_position() -> Vector2:
	return opponent.start_position
