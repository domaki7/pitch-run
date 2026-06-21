class_name RunData
extends Resource

var match_number: int = 1
var difficulty_level: int = 1
var max_lives: int = 1
var lives_remaining: int = 1
var run_stats: Dictionary = {
	"goals_scored": 0,
	"goals_conceded": 0,
	"tackles_made": 0,
	"matches_won": 0,
	"matches_lost": 0,
}
var active_modifiers: Array[Resource] = []
var run_currency: int = 0


func reset(starting_max_lives: int) -> void:
	match_number = 1
	difficulty_level = 1
	max_lives = starting_max_lives
	lives_remaining = starting_max_lives
	run_stats = {
		"goals_scored": 0,
		"goals_conceded": 0,
		"tackles_made": 0,
		"matches_won": 0,
		"matches_lost": 0,
	}
	active_modifiers.clear()
	run_currency = 0


func record_match_result(is_win: bool, goals_for: int, goals_against: int) -> void:
	run_stats["goals_scored"] += goals_for
	run_stats["goals_conceded"] += goals_against
	if is_win:
		run_stats["matches_won"] += 1
	else:
		run_stats["matches_lost"] += 1


func increment_match() -> void:
	match_number += 1
	difficulty_level = match_number
