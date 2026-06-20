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
