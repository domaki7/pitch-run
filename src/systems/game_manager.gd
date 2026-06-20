extends Node

enum GameState { PLAYING, PAUSED }

var current_state: GameState = GameState.PLAYING
var current_player: CharacterBody2D = null
var current_ball: RigidBody2D = null

func register_player(player: CharacterBody2D) -> void:
	current_player = player

func register_ball(ball: RigidBody2D) -> void:
	current_ball = ball
