# Todo — Prototype Build

Target: Player + Ball + Pitch + Debug GUI. No opponents, teammates, scoring, tackle, or roguelike systems.

## Phase 1 — Project Foundation ✓

- [x] Create directory structure (src/components/, src/entities/player/states/, src/entities/ball/, src/states/, src/systems/, src/ui/debug/, src/ui/hud/, assets/sprites/player/, assets/sprites/ball/, assets/sprites/pitch/, levels/)
- [x] Register input actions in project.godot (move_up, move_down, move_left, move_right, pass_ball, shoot, sprint)
- [x] Configure physics collision layers 1-4 in project.godot (Pitch, PlayerTeam, OpponentTeam, Ball)
- [x] Create EventBus autoload (src/systems/event_bus.gd) — signal declarations only
- [x] Create GameManager autoload (src/systems/game_manager.gd) — game state enum, current_player ref

## Phase 2 — State Machine Framework ✓

- [x] Create State base class (src/states/state.gd) — enter/exit/process/physics_process/input virtuals, transition_requested signal
- [x] Create StateMachine component (src/components/state_machine.gd + .tscn) — manages child State nodes, handles transitions via StringName

## Phase 3 — Core Components ✓

- [x] Create MovementComponent (src/components/movement_component.gd + .tscn) — apply_movement(direction, delta), @export speed/acceleration/friction/sprint_multiplier
- [x] Create StaminaComponent (src/components/stamina_component.gd + .tscn) — sprint drain, regen with delay, @export max_stamina/regen_rate/regen_delay/sprint_drain_rate, signals: stamina_changed/stamina_depleted
- [x] Create BallControlComponent (src/components/ball_control_component.gd + .tscn) — dribble logic, ball follows entity at offset, signals: ball_received/ball_lost
- [x] Create KickComponent (src/components/kick_component.gd + .tscn) — applies force to ball RigidBody2D, @export pass_force/shot_force

## Phase 4 — SVG Assets ✓

- [x] Create player SVG (assets/sprites/player/player_default.svg) — top-down geometric shape, flat team color, readable at ~32px
- [x] Create ball SVG (assets/sprites/ball/ball.svg) — simple circle, distinct color
- [x] Create pitch boundary/line visuals (assets/sprites/pitch/) — optional, can use ColorRect initially

## Phase 5 — Ball Entity ✓

- [x] Create Ball scene (src/entities/ball/ball.tscn + ball.gd) — RigidBody2D, PhysicsMaterial2D (friction + damping), CollisionShape2D (CircleShape2D), Sprite2D, BallState enum (FREE/POSSESSED/IN_FLIGHT), possessor tracking
- [x] Add current_ball ref + register_ball() to GameManager
- [x] Wire BallControlComponent and KickComponent to call Ball state methods
- [x] Create temporary test scene (levels/test_scene.tscn) — ball + boundary walls, set as main scene. Replace with proper pitch scene in Phase 8.

## Phase 6 — Player States ✓

- [x] Create PlayerState base (src/entities/player/states/player_state.gd) — typed player ref via await owner.ready, component refs (movement, stamina, ball_control, kick), get_input_direction(), _is_input_enabled()
- [x] Create IdleState (src/entities/player/states/idle_state.gd) — no movement, transitions to RunState on input, DribbleState on ball received
- [x] Create RunState (src/entities/player/states/run_state.gd) — movement without ball, transitions to SprintState on sprint, DribbleState on ball pickup
- [x] Create DribbleState (src/entities/player/states/dribble_state.gd) — movement with ball, pass/shoot input releases ball and transitions to RunState
- [x] Create SprintState (src/entities/player/states/sprint_state.gd) — faster movement, stamina drain, works with/without ball, drops to RunState/DribbleState on stamina depletion or sprint release

## Phase 7 — Player Scene ✓

- [x] Create Player scene (src/entities/player/player.tscn + player.gd) — CharacterBody2D, CollisionShape2D (CircleShape2D), Sprite2D, StateMachine with state nodes, all components as children
- [x] Wire component refs in player.gd _ready(), start state machine via call_deferred
- [x] Set collision layers: layer 2 (PlayerTeam), mask 1+4 (Pitch+Ball)

## Phase 8 — Pitch & Main Scene ✓

- [x] Create pitch scene (levels/pitch.tscn) — StaticBody2D walls on layer 1, visible boundaries, playable area sized for one player
- [x] Create main game scene (levels/main.tscn) — instances Player + Ball + Pitch, Camera2D following player
- [x] Set as project main scene in project.godot

## Phase 9 — Debug GUI ✓

- [x] Create debug_gui.gd (src/ui/debug/debug_gui.gd) — Alt toggle, TabContainer, mouse cursor show/hide, sets visibility flag for input guard
- [x] Create Movement debug tab (src/ui/debug/debug_movement_gui.gd) — float sliders for speed/acceleration/friction/sprint_multiplier, per-value reset buttons, copy changed values to clipboard
- [x] Create Stamina debug tab (src/ui/debug/debug_stamina_gui.gd) — float sliders for max_stamina/regen_rate/regen_delay/sprint_drain_rate, per-value reset, copy to clipboard
- [x] Create Ball Physics debug tab (src/ui/debug/debug_ball_gui.gd) — mass/friction/damping/kick forces, per-value reset, copy to clipboard

## Phase 10 — HUD ✓

- [x] Create HUD scene (src/ui/hud/hud.tscn + hud.gd) — stamina bar, current state label
- [x] Instance DebugGUI as child of HUD
- [x] Wire HUD into main game scene

## Phase 11 — Goal Zones + Scoring ✓

- [x] Add EventBus signals (goal_scored, match_ended, kickoff_started)
- [x] Create goal SVG assets (goal_posts.svg, goal_net.svg)
- [x] Create GoalZone entity (src/entities/goal_zone/goal_zone.gd + .tscn) — Area2D on layer 9, detects ball, emits EventBus.goal_scored
- [x] Overhaul GameManager — MatchState enum (KICKOFF/PLAYING/GOAL_SCORED/MATCH_OVER), score tracking, kickoff reset flow, first-to-3 win condition
- [x] Update PlayerState input guard to use GameManager.is_input_disabled()
- [x] Add Player.reset_for_kickoff() and Ball.reset_to_position() for kickoff resets
- [x] Add HUD score display (top-center) + match end overlay (win/lose + restart)
- [x] Add GoalLeft (team 1) and GoalRight (team 2) instances to pitch.tscn

---

## Deferred (post-prototype)

- TackleHitboxComponent + TackleHurtboxComponent
- TackleState + StunnedState
- Opponent AI entities
- Teammate AI entities
- RunManager + roguelike run loop
- MetaProgressionManager + SaveManager
- SceneManager + scene transitions
- AudioManager
