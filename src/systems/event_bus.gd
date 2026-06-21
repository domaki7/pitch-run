extends Node

signal goal_scored(scoring_team: int, scored_on_team: int)
signal match_ended(winning_team: int, home_score: int, away_score: int)
signal kickoff_started

signal run_started(run_data: RunData)
signal run_ended(run_data: RunData, reason: String)
signal match_completed(match_number: int, is_win: bool, run_data: RunData)
signal pre_match_started(match_number: int)
signal upgrade_selected(upgrade: Resource)
