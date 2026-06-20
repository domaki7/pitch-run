# Todo — Prototype Build

Target: Player + Ball + Pitch + Debug GUI. No opponents, teammates, scoring, tackle, or roguelike systems.

## Phase 1 — Project Foundation

- [ ] Create directory structure (src/components/, src/entities/player/states/, src/entities/ball/, src/states/, src/systems/, src/ui/debug/, src/ui/hud/, assets/sprites/player/, assets/sprites/ball/, assets/sprites/pitch/, levels/)
- [ ] Register input actions in project.godot (move_up, move_down, move_left, move_right, pass_ball, shoot, sprint)
- [ ] Configure physics collision layers 1-4 in project.godot (Pitch, PlayerTeam, OpponentTeam, Ball)
- [ ] Create EventBus autoload (src/systems/event_bus.gd) — signal declarations only
- [ ] Create GameManager autoload (src/systems/game_manager.gd) — game state enum, current_player ref

## Phase 2 — State Machine Framework

- [ ] Create State base class (src/states/state.gd) — enter/exit/process/physics_process/input virtuals, transition_requested signal
- [ ] Create StateMachine component (src/components/state_machine.gd + .tscn) — manages child State nodes, handles transitions via StringName

## Phase 3 — Core Components

- [ ] Create MovementComponent (src/components/movement_component.gd + .tscn) — apply_movement(direction, delta), @export speed/acceleration/friction/sprint_multiplier
- [ ] Create StaminaComponent (src/components/stamina_component.gd + .tscn) — sprint drain, regen with delay, @export max_stamina/regen_rate/regen_delay/sprint_drain_rate, signals: stamina_changed/stamina_depleted
- [ ] Create BallControlComponent (src/components/ball_control_component.gd + .tscn) — dribble logic, ball follows entity at offset, signals: ball_received/ball_lost
- [ ] Create KickComponent (src/components/kick_component.gd + .tscn) — applies force to ball RigidBody2D, @export pass_force/shot_force

## Phase 4 — SVG Assets

- [ ] Create player SVG (assets/sprites/player/player_default.svg) — top-down geometric shape, flat team color, readable at ~32px
- [ ] Create ball SVG (assets/sprites/ball/ball.svg) — simple circle, distinct color
- [ ] Create pitch boundary/line visuals (assets/sprites/pitch/) — optional, can use ColorRect initially

## Phase 5 — Ball Entity

- [ ] Create Ball scene (src/entities/ball/ball.tscn + ball.gd) — RigidBody2D, PhysicsMaterial2D (friction + damping), CollisionShape2D (CircleShape2D), Sprite2D, BallState enum (FREE/POSSESSED/IN_FLIGHT), possessor tracking

## Phase 6 — Player States

- [ ] Create PlayerState base (src/entities/player/states/player_state.gd) — typed player ref via await owner.ready, component refs (movement, stamina, ball_control, kick), get_input_direction(), _is_input_enabled()
- [ ] Create IdleState (src/entities/player/states/idle_state.gd) — no movement, transitions to RunState on input, DribbleState on ball received
- [ ] Create RunState (src/entities/player/states/run_state.gd) — movement without ball, transitions to SprintState on sprint, DribbleState on ball pickup
- [ ] Create DribbleState (src/entities/player/states/dribble_state.gd) — movement with ball, pass/shoot input releases ball and transitions to RunState
- [ ] Create SprintState (src/entities/player/states/sprint_state.gd) — faster movement, stamina drain, works with/without ball, drops to RunState/DribbleState on stamina depletion or sprint release

## Phase 7 — Player Scene

- [ ] Create Player scene (src/entities/player/player.tscn + player.gd) — CharacterBody2D, CollisionShape2D (CircleShape2D), Sprite2D, StateMachine with state nodes, all components as children
- [ ] Wire component refs in player.gd _ready(), start state machine via call_deferred
- [ ] Set collision layers: layer 2 (PlayerTeam), mask 1+4 (Pitch+Ball)

## Phase 8 — Pitch & Main Scene

- [ ] Create pitch scene (levels/pitch.tscn) — StaticBody2D walls on layer 1, visible boundaries, playable area sized for one player
- [ ] Create main game scene (levels/main.tscn) — instances Player + Ball + Pitch, Camera2D following player
- [ ] Set as project main scene in project.godot

## Phase 9 — Debug GUI

- [ ] Create debug_gui.gd (src/ui/debug/debug_gui.gd) — Alt toggle, TabContainer, mouse cursor show/hide, sets visibility flag for input guard
- [ ] Create Movement debug tab (src/ui/debug/debug_movement_gui.gd) — float sliders for speed/acceleration/friction/sprint_multiplier, per-value reset buttons, copy changed values to clipboard
- [ ] Create Stamina debug tab (src/ui/debug/debug_stamina_gui.gd) — float sliders for max_stamina/regen_rate/regen_delay/sprint_drain_rate, per-value reset, copy to clipboard
- [ ] Create Ball Physics debug tab (src/ui/debug/debug_ball_gui.gd) — mass/friction/damping/kick forces, per-value reset, copy to clipboard

## Phase 10 — HUD

- [ ] Create HUD scene (src/ui/hud/hud.tscn + hud.gd) — stamina bar, current state label
- [ ] Instance DebugGUI as child of HUD
- [ ] Wire HUD into main game scene

---

## Deferred (post-prototype)

- TackleHitboxComponent + TackleHurtboxComponent
- TackleState + StunnedState
- Opponent AI entities
- Teammate AI entities
- Goal zones + scoring
- RunManager + roguelike run loop
- MetaProgressionManager + SaveManager
- SceneManager + scene transitions
- AudioManager
