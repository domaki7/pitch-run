# PitchRun

2D top-down soccer roguelike built in Godot 4.x with GDScript. Uses built-in 2D physics.

## Tooling

Use PowerShell for any file inspection tasks (reading files, binary files, etc.). Never use Python.

**Never run git commands autonomously.** Do not stage, commit, push, or run any git operations without explicit user instruction for each command.

@architecture.md
@style.md
@entities.md
@patterns.md
@debug.md
@todo.md

## Directory Structure

```
res://
  src/components/       Reusable component nodes (.gd + .tscn pairs)
  src/entities/         Entity scenes that compose components
    player/             Player-controlled footballer, player-specific states
    teammates/          AI teammate types, each in own subfolder with states
    opponents/          AI opponent types, each in own subfolder with states
    ball/               Ball entity (RigidBody2D)
  src/systems/          Autoloaded singletons (GameManager, EventBus, RunManager, etc.)
  src/states/           Base state machine framework (State, StateMachine)
  src/ui/               All UI (hud/, menus/, debug/, run_summary/)
  resources/            Custom Resource scripts and .tres data files
    formations/         FormationData resources (positions, roles)
    unlocks/            UnlockData, SkillData resources + definitions/
    run_modifiers/      RunModifier resources (buffs, curses, mutators)
  levels/               Pitch/match scenes, arena variants
  assets/               Raw assets only (sprites/, audio/, fonts/, shaders/, tilesets/)
  addons/               Third-party editor plugins
```

## Physics Collision Layers

| Layer | Name | Purpose |
|-------|------|---------|
| 1 | Pitch | Environment walls, boundaries |
| 2 | PlayerTeam | Player-controlled team bodies |
| 3 | OpponentTeam | AI opponent bodies |
| 4 | Ball | Football RigidBody2D |
| 5 | PlayerTackleHitbox | Player team tackle zones |
| 6 | OpponentTackleHitbox | Opponent tackle zones |
| 7 | PlayerHurtbox | Player team hurtboxes |
| 8 | OpponentHurtbox | Opponent hurtboxes |
| 9 | GoalZone | Goal detection areas |
| 10 | Interactable | Pickups, powerups |
| 11 | Trigger | Event trigger zones |
