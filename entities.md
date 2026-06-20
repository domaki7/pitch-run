# Game Entities

## Player Entity

Player scene tree (`src/entities/player/player.tscn`):
```
Player (CharacterBody2D)             player.gd, layer 2, mask 1+3+4
  CollisionShape2D                   CircleShape2D
  Sprite2D                           assets/sprites/player/player_default.svg
  StateMachine                       state_machine.gd
    IdleState                        idle_state.gd
    RunState                         run_state.gd
    DribbleState                     dribble_state.gd
    TackleState                      tackle_state.gd
    SprintState                      sprint_state.gd
    StunnedState                     stunned_state.gd
  MovementComponent                  movement_component.gd
  StaminaComponent                   stamina_component.gd
  BallControlComponent               ball_control_component.gd
  KickComponent                      kick_component.gd
  TackleHitboxComponent              tackle_hitbox_component.gd, layer 5 (PlayerTackleHitbox)
    CollisionShape2D                 CircleShape2D
  TackleHurtboxComponent             tackle_hurtbox_component.gd, layer 7 (PlayerHurtbox), mask 6 (OpponentTackleHitbox)
    CollisionShape2D                 CircleShape2D
  Camera2D                           Follows active footballer
```

The player script is a thin orchestrator: wires component references in `_ready()`, registers with GameManager, starts state machine via `call_deferred`.

## Player States

All extend `PlayerState` (`src/entities/player/states/player_state.gd`), which provides `player`, `movement`, `stamina`, `ball_control`, `kick` refs, `get_input_direction() -> Vector2` (WASD, no camera basis needed for top-down), and `_is_input_enabled() -> bool` (returns false when `GameManager.is_input_disabled()` -- debug GUI open or match state is not PLAYING). All input checks in states are guarded by `_is_input_enabled()`.

- **IdleState** -- standing still, no ball. Transitions to RunState on movement input, DribbleState if receiving ball.
- **RunState** -- moving without ball. Transitions to DribbleState on ball pickup, TackleState on tackle input, SprintState on sprint input.
- **DribbleState** -- moving with ball. Ball follows entity. Transitions to RunState on kick/pass (ball released), SprintState on sprint input.
- **TackleState** -- brief lunge to steal ball. Activates TackleHitboxComponent. On hit: dispossess target. On miss: transitions to StunnedState.
- **SprintState** -- faster movement, drains stamina. Applicable with or without ball. Drops to RunState/DribbleState on stamina depletion or sprint release.
- **StunnedState** -- brief state lock after being tackled or failed tackle. No input accepted. Transitions to IdleState after stun duration.

## Teammate AI Entity

```
Teammate (CharacterBody2D)           teammate.gd, layer 2, mask 1+3+4
  CollisionShape2D                   CircleShape2D
  Sprite2D                           assets/sprites/teammates/teammate_default.svg
  StateMachine                       state_machine.gd
    IdleState                        Positioned in formation
    RunToPositionState               Moving to tactical position
    SupportRunState                  Making runs for passes
    DribbleState                     AI dribbling
    PassState                        AI passing
  MovementComponent                  movement_component.gd
  BallControlComponent               ball_control_component.gd
  KickComponent                      kick_component.gd
  TackleHitboxComponent              layer 5 (PlayerTackleHitbox)
    CollisionShape2D                 CircleShape2D
  TackleHurtboxComponent             layer 7 (PlayerHurtbox), mask 6 (OpponentTackleHitbox)
    CollisionShape2D                 CircleShape2D
```

Teammate AI uses the same components as the player. The difference is the state machine contains AI decision states instead of input-reading states. Base state `TeammateState extends State` provides helpers: `get_ball_position() -> Vector2`, `get_nearest_opponent() -> CharacterBody2D`, `get_formation_position() -> Vector2`.

Player switching (Tab key) transfers camera and input control to the nearest teammate. The formerly-controlled entity becomes an AI teammate. This works because player and teammate entities share the same component set.

## Opponent AI Entity

```
Opponent (CharacterBody2D)           opponent.gd, layer 3, mask 1+2+4
  CollisionShape2D                   CircleShape2D
  Sprite2D                           assets/sprites/opponents/opponent_default.svg
  StateMachine                       state_machine.gd
    IdleState                        Positioned in formation
    ChaseState                       Pursuing ball carrier
    TackleState                      Attempting tackle
    DribbleState                     AI dribbling after winning ball
    PassState                        AI passing
    ReturnToPositionState            Falling back to formation
  MovementComponent                  movement_component.gd
  BallControlComponent               ball_control_component.gd
  KickComponent                      kick_component.gd
  TackleHitboxComponent              layer 6 (OpponentTackleHitbox)
    CollisionShape2D                 CircleShape2D
  TackleHurtboxComponent             layer 8 (OpponentHurtbox), mask 5 (PlayerTackleHitbox)
    CollisionShape2D                 CircleShape2D
```

Base state `OpponentState extends State` provides helpers: `get_ball_carrier() -> CharacterBody2D`, `get_distance_to_ball() -> float`, `get_direction_to_ball() -> Vector2`. Add `add_to_group("opponents")` in `_ready()` so the debug GUI can discover opponents at runtime.

## Ball Entity

```
Ball (RigidBody2D)                   ball.gd, layer 4, mask 1+2+3
  CollisionShape2D                   CircleShape2D
  Sprite2D                           assets/sprites/ball/ball.svg
```

The ball is a RigidBody2D -- physics forces for kicks, passes, shots. Friction and damping applied via PhysicsMaterial2D. The ball script tracks possession with a simple enum state:

```gdscript
enum BallState { FREE, POSSESSED, IN_FLIGHT }
var current_state: BallState = BallState.FREE
var possessor: CharacterBody2D = null
```

No full state machine needed -- the ball is a passive physics object controlled by entity components (KickComponent, BallControlComponent).

## Goal Zones

```
GoalZone (Area2D)                    goal_zone.gd, layer 9 (value 256), mask 4 (Ball, value 8)
  CollisionShape2D                   RectangleShape2D(30, 220) covering goal mouth
  GoalPosts (Sprite2D)              goal_posts.svg
  NetArea (Sprite2D)                 goal_net.svg, positioned behind wall based on team
```

Detects ball entering via `body_entered`. Emits `EventBus.goal_scored(scoring_team, scored_on_team)`. Two instances in pitch.tscn: GoalLeft at (0, 450) with team=1, GoalRight at (1600, 450) with team=2. Convention: team 1 = home/player (defends left), team 2 = away/opponent (defends right). Uses `_has_scored_this_play` flag to prevent double-detection from ball bouncing. Joins `"goal_zones"` group for batch reset via `get_tree().call_group()`.

## Input Actions

| Action | Key | Used by |
|--------|-----|---------|
| `move_up` | W | PlayerState.get_input_direction() |
| `move_down` | S | PlayerState.get_input_direction() |
| `move_left` | A | PlayerState.get_input_direction() |
| `move_right` | D | PlayerState.get_input_direction() |
| `pass_ball` | LMB / E | DribbleState (pass to nearest teammate) |
| `shoot` | RMB / Q | DribbleState (shoot toward goal) |
| `tackle` | Space | RunState, SprintState (attempt tackle) |
| `sprint` | Shift | RunState, DribbleState (faster movement) |
| `switch_player` | Tab | Any state (switch control to nearest teammate) |
| (Alt key) | Alt | Debug GUI toggle (debug_gui.gd) |
