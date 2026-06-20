# Architecture

Component-based entity composition. Entities (player, teammates, opponents) are CharacterBody2D scenes that compose reusable Component nodes as children. The ball is a RigidBody2D with its own components. Components are standalone -- they carry their own logic and expose @export vars for designer tuning.

## Core Rules

1. **Every tunable value must be @export.** Never hardcode numbers that a designer might want to change. Speed, stamina, kick force, ranges, durations, cooldowns -- all @export.
2. **Components are reusable nodes.** Each component is a .tscn with a root script. Instance it as a child of any entity that needs that behavior. Do not put component logic in the entity script.
3. **Entity scripts are thin.** The entity .gd file wires components together and handles entity-specific input or orchestration. It should not contain movement math, stamina logic, or ball physics -- those belong in components.
4. **Static typing everywhere.** Every variable, parameter, and return type must have an explicit type annotation. Use `-> void` on all functions that return nothing.
5. **No magic strings for node paths.** Entity scripts wire component references via `$NodeName` in `_ready()`. Components find their owner entity via `get_parent()`. Never use string-based `get_node("../SomeComponent")` with relative paths.
6. **Signals for events, methods for commands.** Components emit signals when something happens (tackled, ball_lost, goal_scored). Other nodes call methods to make things happen (kick, tackle, sprint).

## Autoloads

Registered in project.godot. Access globally by name. **Autoload scripts must NOT use `class_name`** -- the autoload name already registers a global identifier, and `class_name` with the same name causes a parser error.

- **GameManager** -- match state machine (KICKOFF/PLAYING/GOAL_SCORED/MATCH_OVER), current player/ball references, score tracking (first to 3), kickoff reset flow, `is_input_disabled()` centralizes input gating (debug GUI + match state)
- **EventBus** -- signal-only singleton for decoupled cross-system events. No logic, only signal declarations. Current signals: `goal_scored(scoring_team, scored_on_team)`, `match_ended(winning_team, home_score, away_score)`, `kickoff_started`.
- **RunManager** -- current run state (run seed, match number, accumulated rewards, active modifiers, run stats). Manages run lifecycle: start, advance match, end (victory/permadeath). Persists within a run but resets on new run.
- **MetaProgressionManager** -- persistent unlocks, currency that survives permadeath, unlock tree state. Reads/writes via SaveManager. Tracks lifetime stats.
- **SaveManager** -- save/load to user://, meta progression persistence, run history
- **AudioManager** -- SFX/music playback, audio bus management, pooling
- **SceneManager** -- async scene transitions with loading screen, fade effects

## Component Pattern

### Creating a New Component

1. Create `src/components/my_component.gd`:

```gdscript
class_name MyComponent
extends Node

signal something_happened(value: float)

@export var my_value: float = 10.0
@export var my_flag: bool = true

func do_thing() -> void:
    something_happened.emit(my_value)
```

2. Create `src/components/my_component.tscn` with that script as root node. Add any child nodes the component needs (CollisionShape2D for Area2D components, Timer nodes, etc.).

3. Instance the .tscn as a child of any entity that needs it.

### Component Communication

**Direct references (required dependencies):**
```gdscript
# Entity script wires in _ready():
movement_component = $MovementComponent as MovementComponent
# Component finds its body in _ready():
body = get_parent() as CharacterBody2D
```
Entity scripts use `$NodeName` to get component references. Components use `get_parent()` to find their owning entity.

**Local signals (same-entity events):**
```gdscript
# Component emits:
signal ball_lost
# Entity script or sibling connects in _ready():
ball_control.ball_lost.connect(_on_ball_control_ball_lost)
```

**EventBus (cross-system events):**
```gdscript
EventBus.goal_scored.emit(team, scorer)
EventBus.goal_scored.connect(_on_goal_scored)
```

**Rule:** @export reference for "I need to call your methods." Signal for "I'm announcing something happened." EventBus for "Systems that don't know about me need to react."

### Existing Components

Components will be documented here as they are created. Planned components:

- **MovementComponent** -- Movement for CharacterBody2D. Finds body via `get_parent()`. Call `apply_movement(direction, delta)`. Does NOT read input -- receives direction from caller.
- **StaminaComponent** -- Stamina tracking, sprint drain, regen with delay. `@export max_stamina`, `regen_rate`, `regen_delay`, `sprint_drain_rate`, `tackle_cost`. Signals: `stamina_changed`, `stamina_depleted`.
- **BallControlComponent** -- Dribbling, receiving passes. Tracks whether entity has ball possession. Signals: `ball_received`, `ball_lost`.
- **KickComponent** -- Pass and shoot mechanics. Applies force to ball RigidBody2D. `@export pass_force`, `shot_force`.
- **TackleHitboxComponent** -- Area2D tackle zone. Starts deactivated. Call `activate()` / `deactivate()`. Set `monitoring = false`, `monitorable = true`. Emits `tackle_hit(hurtbox)`.
- **TackleHurtboxComponent** -- Area2D that receives tackles. Set `monitoring = true`, `monitorable = false`. On overlap with TackleHitboxComponent: emits `tackled(hitbox)`, triggers ball dispossession.
- **HealthComponent** -- HP tracking for roguelike injury mechanics. `take_damage()`, `heal()`. Signals: `died`, `health_changed`.
- **AnimationComponent** -- Sprite animation wrapper. AnimatedSprite2D or AnimationPlayer. Call `play(animation_name)`. Emits `animation_finished`.

## State Machine Pattern

States are Node children of a StateMachineComponent. Each state extends the base State class.

### Creating Entity States

1. Create a base state for the entity type if needed (e.g., `PlayerState extends State` with a typed player reference).
2. Create concrete states in `src/entities/<entity>/states/`.
3. Each state calls `transition_requested.emit(self, &"TargetStateName")` to request transitions.
4. State node names in the scene tree must match the StringName used in transitions: node `IdleState` -> `&"IdleState"`.

### State Machine Initialization

Do NOT use `initial_state` export on StateMachine for entities that need component references. Instead, the entity script starts the state machine via `call_deferred` after wiring all references in `_ready()`:
```gdscript
func _ready() -> void:
    state_machine = $StateMachine as StateMachine
    movement_component = $MovementComponent as MovementComponent
    # ... wire other references ...
    _start_state_machine.call_deferred()

func _start_state_machine() -> void:
    state_machine.transition_to(&"IdleState")
```
Entity-specific base states (e.g., `PlayerState`) use `await owner.ready` in `_ready()` to get references after the entity has wired them. The deferred start ensures all `_ready()` and await continuations complete before `enter()` is called.
