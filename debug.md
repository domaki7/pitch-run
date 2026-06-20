# Debug GUI

In-game debug panel for tweaking `@export` variables at runtime. Press **Alt** to toggle: shows the panel, releases the mouse cursor, and disables all game input (movement, tackle, sprint, pass, shoot). Press Alt again to hide and resume gameplay.

## Architecture

The debug GUI is a **tabbed system** managed by `debug_gui.gd`. The master controller handles Alt key toggle, mouse cursor, and a TabContainer. Each tab is a separate script extending Control that receives its target component via `setup()` and builds controls programmatically.

Located in `src/ui/debug/`. Instanced as a child of the HUD scene (`src/ui/hud/hud.tscn`).

## Current Tabs

Tabs will be documented here as they are created. Planned tabs:

- **Movement** -- tweaks MovementComponent values: speed, acceleration, friction, sprint_multiplier. Per-value reset buttons and "Copy Values to Clipboard".
- **Stamina** -- tweaks StaminaComponent values: max_stamina, regen_rate, regen_delay, sprint_drain_rate, tackle_cost. Per-value reset buttons and "Copy Values to Clipboard".
- **Ball Physics** -- tweaks ball RigidBody2D properties: mass, friction, kick_force, pass_force, shot_force, damping. Per-value reset buttons and "Copy Values to Clipboard".
- **Combat** -- tweaks tackle hitbox/hurtbox collision shapes for player and opponents. Invulnerable checkboxes. Shape visualization overlays (red for hitbox, blue for hurtbox). Auto-discovers opponents via `"opponents"` group.
- **AI** -- tweaks AI behavior parameters: detection_range, chase_speed, formation_tightness, aggression. Applied to all AI entities via group discovery.

## Adding a New Debug Tab

1. Create `src/ui/debug/debug_<component>_gui.gd` extending Control
2. Add a `setup(component: <ComponentType>) -> void` method that stores the reference and calls `_build_controls()`
3. In `_ready()`, create a ScrollContainer + VBoxContainer for the tab's content. **Important:** call `_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)` on the ScrollContainer so it fills the tab area (plain Control parents don't respect `size_flags`).
4. Build controls programmatically in `_build_controls()`:
   - `_add_header(group_name)` for section labels
   - `_add_float_control(property, min, max, step)` for float exports (includes per-value reset button)
   - `_add_vector2_control(property, min, max, step)` for Vector2 exports (includes per-axis reset buttons)
   - `_add_checkbox_control(label, callback)` for boolean toggles (returns CheckBox)
5. On value change, write directly to the component property. For position properties that need immediate visual feedback, also update the relevant node transforms. Reset buttons auto-show when a value differs from its default and auto-hide when reset.
6. Add a "Copy Values to Clipboard" button that serializes only changed values to JSON via `DisplayServer.clipboard_set()`
7. Register the tab in `debug_gui.gd`'s `_bind_to_player()` method: instantiate the script, set `name` (used as tab label), add to TabContainer, call `setup()`

For ball-specific tabs, pass the ball reference separately -- either via GameManager or discovered via group.

## Input Guard

When the debug panel is visible (`debug_gui.visible == true`):
- `PlayerState._is_input_enabled()` returns `false`, blocking all movement, tackle, sprint, pass, shoot input
- All states guard their `Input.is_action_just_pressed()` calls with `_is_input_enabled()`

Top-down games do not capture the mouse during gameplay, so the input guard uses a dedicated visibility flag rather than `Input.mouse_mode`.

## Export Format

The "Copy Values to Clipboard" button produces JSON containing only properties that differ from their defaults:
```json
{
  "property_name": 0.5,
  "vector2_property": { "x": 0.1, "y": -0.2 }
}
```
If no values have been changed, the output is `{}`. Paste this to Claude to apply values to the scene/script defaults.
