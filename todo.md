# Todo — Post-Prototype

Prototype complete: player + ball + pitch + scoring + debug GUI. Next: combat, AI, roguelike systems, infrastructure.

---

## Combat

- [ ] Register `tackle` input action in project.godot (Space key)
- [ ] Create TackleHitboxComponent (src/components/tackle_hitbox_component.gd + .tscn) — Area2D, starts deactivated, `activate()`/`deactivate()`, `monitoring = false`, `monitorable = true`, layer 5 (PlayerTackleHitbox) or 6 (OpponentTackleHitbox) depending on entity. Signal: `tackle_hit(hurtbox)`
- [ ] Create TackleHurtboxComponent (src/components/tackle_hurtbox_component.gd + .tscn) — Area2D, `monitoring = true`, `monitorable = false`, layer 7 (PlayerHurtbox) mask 6 (OpponentTackleHitbox) or layer 8 (OpponentHurtbox) mask 5 (PlayerTackleHitbox). Checks ball possession via BallControlComponent, triggers dispossession. Signal: `tackled(hitbox)`
- [ ] Create TackleState (src/entities/player/states/tackle_state.gd) — brief lunge, activates TackleHitboxComponent, on hit: dispossess target, on miss: transition to StunnedState
- [ ] Create StunnedState (src/entities/player/states/stunned_state.gd) — brief state lock after failed tackle or being tackled, no input, @export stun_duration, transitions to IdleState after duration
- [ ] Wire TackleHitboxComponent + TackleHurtboxComponent into Player scene (player.tscn) with CollisionShape2D children
- [ ] Add tackle transitions: RunState/SprintState → TackleState on tackle input, TackleHurtboxComponent.tackled → StunnedState
- [ ] Create Combat debug tab (src/ui/debug/debug_combat_gui.gd) — tackle hitbox/hurtbox shape tweaking, invulnerable checkbox, shape visualization overlays. Auto-discover opponents via `"opponents"` group. Register in debug_gui.gd

## AI

- [ ] Create opponent SVG (assets/sprites/opponents/opponent_default.svg) — distinct team color, same top-down style
- [ ] Create teammate SVG (assets/sprites/teammates/teammate_default.svg) — same team color as player, variant shape
- [ ] Create OpponentState base (src/entities/opponents/states/opponent_state.gd) — extends State, typed opponent ref, helpers: `get_ball_carrier()`, `get_distance_to_ball()`, `get_direction_to_ball()`
- [ ] Create Opponent entity (src/entities/opponents/opponent.gd + opponent.tscn) — CharacterBody2D, layer 3, mask 1+2+4, components: MovementComponent, BallControlComponent, KickComponent, TackleHitboxComponent (layer 6), TackleHurtboxComponent (layer 8, mask 5). `add_to_group("opponents")`
- [ ] Create Opponent states (src/entities/opponents/states/) — IdleState, ChaseState, TackleState, DribbleState, PassState, ReturnToPositionState
- [ ] Create TeammateState base (src/entities/teammates/states/teammate_state.gd) — extends State, typed teammate ref, helpers: `get_ball_position()`, `get_nearest_opponent()`, `get_formation_position()`
- [ ] Create Teammate entity (src/entities/teammates/teammate.gd + teammate.tscn) — CharacterBody2D, layer 2, mask 1+3+4, components: MovementComponent, BallControlComponent, KickComponent, TackleHitboxComponent (layer 5), TackleHurtboxComponent (layer 7, mask 6). `add_to_group("teammates")`
- [ ] Create Teammate states (src/entities/teammates/states/) — IdleState, RunToPositionState, SupportRunState, DribbleState, PassState
- [ ] Create FormationData resource (resources/formations/) — position offsets, role assignments per formation
- [ ] Implement player switching (Tab key) — transfer camera + input control to nearest teammate, former player becomes AI teammate
- [ ] Create AI debug tab (src/ui/debug/debug_ai_gui.gd) — detection_range, chase_speed, formation_tightness, aggression. Apply to all AI via group discovery. Register in debug_gui.gd
- [ ] Instance opponents + teammates in pitch.tscn, wire kickoff reset positions

## Roguelike Systems

- [ ] Create RunManager autoload (src/systems/run_manager.gd) — run lifecycle: start, advance match, end. Tracks: run seed, match number, accumulated rewards, active modifiers, run stats. RunData resource for serialization. Register in project.godot
- [ ] Create SaveManager autoload (src/systems/save_manager.gd) — save/load to user://, meta progression persistence, run history. Saveable nodes join `"saveable"` group with `save_data()`/`load_data()`. Register in project.godot
- [ ] Create MetaProgressionManager autoload (src/systems/meta_progression_manager.gd) — persistent unlocks, currency that survives permadeath, unlock tree state. Loads from SaveManager on startup. `is_unlocked(id)` for checking availability. Register in project.godot
- [ ] Create UnlockData resource script (resources/unlocks/) — `cost`, `prerequisite_ids`, `unlock_type` (character, formation, modifier, cosmetic)
- [ ] Create RunModifier resource script (resources/run_modifiers/) — buffs, curses, mutators applied during a run
- [ ] Create HealthComponent (src/components/health_component.gd + .tscn) — HP tracking for roguelike injury mechanics, `take_damage()`, `heal()`, signals: `died`, `health_changed`
- [ ] Implement pre-match flow — opponent preview, modifier/upgrade selection from reward pool
- [ ] Implement post-match flow — award rewards, increment match counter or end run on loss (permadeath)

## Infrastructure

- [ ] Create SceneManager autoload (src/systems/scene_manager.gd) — async scene transitions with loading screen, fade effects. Register in project.godot
- [ ] Create AudioManager autoload (src/systems/audio_manager.gd) — SFX/music playback, audio bus management, pooling. Register in project.godot
- [ ] Create hub/menu scene — run start, meta progression display, unlock tree UI
