# Common Patterns

## Debug GUI Runtime Tuning
Tabbed in-game debug panel (`src/ui/debug/`) for tweaking component `@export` vars at runtime. Alt toggles panel + mouse cursor + disables game input. Each component gets its own tab script. Features: per-value reset buttons that appear when a value is modified, checkbox toggles, and "Copy Values to Clipboard" that exports only changed values as JSON. See `debug.md` for full details and how to add new tabs.

## Tackle Flow
1. TackleHitboxComponent (tackler) overlaps TackleHurtboxComponent (target)
2. TackleHurtboxComponent checks if target has ball possession (via BallControlComponent)
3. If target has ball: dispossess, emit `ball_lost(entity)` signal, ball state becomes FREE
4. TackleHurtboxComponent emits `tackled(hitbox)` signal
5. Target transitions to StunnedState (brief state lock)
6. If tackle has damage (roguelike upgrade): optionally call `health_component.take_damage()`
7. If health <= 0 (roguelike): entity is "injured out" -- removed from current match

## Goal Scoring + Kickoff Flow
GameManager orchestrates the full match flow via MatchState enum (KICKOFF/PLAYING/GOAL_SCORED/MATCH_OVER).

1. Ball enters GoalZone Area2D → `body_entered` fires
2. GoalZone emits `EventBus.goal_scored(scoring_team, scored_on_team)` (guarded by `_has_scored_this_play` to prevent double-detection)
3. GameManager increments score, sets state to GOAL_SCORED → `is_input_disabled()` returns true → player decelerates to idle
4. After `GOAL_CELEBRATION_DELAY` (1.5s), GameManager checks win condition (first to `GOALS_TO_WIN` = 3)
5. **If not won:** `_begin_kickoff(scored_on_team)` → state = KICKOFF, emits `EventBus.kickoff_started`, resets player/ball/goal zones to starting positions, then after `KICKOFF_DELAY` (0.5s) → state = PLAYING
6. **If won:** `_end_match(winner)` → state = MATCH_OVER, emits `EventBus.match_ended` → HUD shows win/lose overlay → any key press triggers `restart_match()`

**Reset methods:** `Player.reset_for_kickoff(pos)` releases ball + teleports + transitions to IdleState. `Ball.reset_to_position(pos)` freezes, clears velocity, teleports, unfreezes. Goal zones reset `_has_scored_this_play` via group call.

**Input gating:** `GameManager.is_input_disabled()` returns true when `is_debug_gui_open` OR `current_state != PLAYING`. All player states check this via `PlayerState._is_input_enabled()`.

## Run Management Pattern
RunManager manages the roguelike run lifecycle:

1. **Start Run** -- RunManager initializes: seed, starting team, starting stats, match counter = 0, clear active modifiers
2. **Pre-Match** -- Show opponent preview, choose modifiers/upgrades from reward pool. SceneManager loads pitch scene.
3. **Match** -- Play the match. RunManager tracks score, time, events. On match end: RunManager records result.
4. **Post-Match** -- If won: award rewards (currency, upgrade choices), increment match counter, return to pre-match. If lost: permadeath -- run ends.
5. **Run End** -- Calculate final rewards. MetaProgressionManager.award_persistent_currency(). Save meta progression. Return to hub/menu.

RunManager holds the run state as a Resource (RunData) so it can be serialized if mid-run saves are needed later.

## Meta Progression Pattern
MetaProgressionManager handles persistent unlocks that survive permadeath:

- Loads unlock state from SaveManager on startup
- Unlock tree: structured as UnlockData resources with `cost`, `prerequisite_ids`, `unlock_type` (character, formation, modifier, cosmetic)
- Currency earned at run end persists via SaveManager
- Unlocked items become available in the pre-match upgrade pool for future runs
- Check `MetaProgressionManager.is_unlocked(id)` before offering an upgrade in the run

## Adding a New Entity
1. Create subfolder in `src/entities/<category>/<entity_name>/` (category is `opponents/`, `teammates/`, or `player/`)
2. Create scene (.tscn) with CharacterBody2D root + CollisionShape2D
3. Add component nodes as children (MovementComponent, BallControlComponent, KickComponent, TackleHitboxComponent, TackleHurtboxComponent)
4. Wire references via `$NodeName` in the entity script's `_ready()`
5. Create `states/` subfolder with a base state (extends State, typed to entity class) and concrete states
6. Start state machine via `call_deferred` in `_ready()`
7. Set collision layers per entity type (reference collision layer table in CLAUDE.md)
8. For opponents: add `add_to_group("opponents")` so debug GUI can discover them
9. For teammates: add `add_to_group("teammates")` for formation manager discovery

## Save/Load
Saveable nodes join the `"saveable"` group and implement:
```gdscript
func save_data() -> Dictionary:
    return { "currency": meta_currency, "unlocks": unlocked_ids }

func load_data(data: Dictionary) -> void:
    meta_currency = data.get("currency", 0)
    unlocked_ids = data.get("unlocks", [])
```

For PitchRun, the primary save target is meta progression data (persistent currency, unlocks, lifetime stats), not mid-match state. Roguelike runs are not saved mid-match in v1.
