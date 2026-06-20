# GDScript Style

## Naming Conventions

- **Files:** `snake_case` for everything (.gd, .tscn, .tres, directories)
- **Node names:** `PascalCase` in scene tree (MovementComponent, PlayerCamera)
- **class_name:** `PascalCase` matching the concept (MovementComponent, FormationData, PlayerIdleState)
- **Signals:** `snake_case`, past tense for events: `tackled`, `ball_lost`, `goal_scored`
- **Signal handlers:** `_on_<emitter_node_name>_<signal_name>`
- **Variables/functions:** `snake_case`. Private with `_` prefix. Booleans use `is_`/`has_`/`can_` prefix.
- **Constants:** `SCREAMING_SNAKE_CASE`
- **Enums:** `PascalCase` name, `SCREAMING_SNAKE_CASE` values

## Asset Naming

SVG files follow `snake_case` like all other files:
- **Pattern:** `<entity>_<variant>.svg` (e.g., `player_default.svg`, `opponent_striker.svg`, `ball.svg`)
- **Directories:** `assets/sprites/<category>/` matches entity categories

## Code Example

```gdscript
class_name MyClassName
extends ParentClass

signal my_signal(param: float)

enum MyEnum { VALUE_A, VALUE_B, VALUE_C }

const MAX_VALUE: int = 100

@export var speed: float = 5.0
@export var max_stamina: float = 100.0
@export_group("Kick")
@export var pass_force: float = 300.0
@export var shot_force: float = 500.0
var movement_component: MovementComponent
var _internal_state: int = 0

func _ready() -> void:
    movement_component = $MovementComponent as MovementComponent

func _physics_process(delta: float) -> void:
    pass

func _unhandled_input(event: InputEvent) -> void:
    pass

func do_public_thing(value: float) -> bool:
    return value > 0.0

func _calculate_internal(x: float) -> float:
    return x * 2.0

func _on_tackle_hurtbox_tackled() -> void:
    queue_free()
```

## Script Section Order

1. class_name and extends
2. Signals
3. Enums
4. Constants
5. @export vars (grouped with @export_group)
6. @onready vars
7. Regular vars (public then private)
8. _ready, _process, _physics_process, _input/_unhandled_input
9. Public methods
10. Private methods
11. Signal handlers

## Type Annotations -- Always Explicit

```gdscript
var stamina: float = 100.0
var teammates: Array[CharacterBody2D] = []
var target: Node2D = null
func calculate(base: float, modifier: float) -> float:
```

## @export Grouping

```gdscript
@export_group("Movement")
@export var speed: float = 5.0
@export var sprint_multiplier: float = 1.5

@export_group("Tackle")
@export var tackle_range: float = 30.0
@export var tackle_cooldown: float = 0.5

```

Component references are wired via `$NodeName` in `_ready()`, not `@export`.
