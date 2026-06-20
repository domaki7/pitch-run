extends Node

signal goal_scored(scoring_team: int, scored_on_team: int)
signal match_ended(winning_team: int, home_score: int, away_score: int)
signal kickoff_started
