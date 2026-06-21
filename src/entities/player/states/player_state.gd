class_name PlayerState
extends State

var player: CharacterBody2D = null
var movement: MovementComponent = null
var stamina: StaminaComponent = null
var ball_control: BallControlComponent = null
var kick: KickComponent = null
var tackle_hitbox: TackleHitboxComponent = null
var tackle_hurtbox: TackleHurtboxComponent = null

func _ready() -> void:
	await owner.ready
	player = owner as CharacterBody2D
	movement = player.movement_component
	stamina = player.stamina_component
	ball_control = player.ball_control_component
	kick = player.kick_component
	tackle_hitbox = player.tackle_hitbox_component
	tackle_hurtbox = player.tackle_hurtbox_component

func get_input_direction() -> Vector2:
	if not _is_input_enabled():
		return Vector2.ZERO
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

func get_mouse_target() -> Vector2:
	return player.get_global_mouse_position()

func _is_input_enabled() -> bool:
	return not GameManager.is_input_disabled() and player == GameManager.current_player
