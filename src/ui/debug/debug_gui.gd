extends PanelContainer

var _tab_container: TabContainer = null
var _is_bound: bool = false

func _ready() -> void:
	_tab_container = $TabContainer as TabContainer
	visible = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_ALT and key_event.pressed and not key_event.echo:
			_toggle()
			get_viewport().set_input_as_handled()

func _toggle() -> void:
	visible = not visible
	GameManager.is_debug_gui_open = visible
	if visible and not _is_bound:
		_bind_to_player()

func _bind_to_player() -> void:
	var player: Player = GameManager.current_player as Player
	var ball: Ball = GameManager.current_ball as Ball
	if player == null:
		return
	_is_bound = true

	var movement_tab: Control = Control.new()
	movement_tab.set_script(preload("res://src/ui/debug/debug_movement_gui.gd"))
	movement_tab.name = "Movement"
	_tab_container.add_child(movement_tab)
	movement_tab.setup(player.movement_component)

	var stamina_tab: Control = Control.new()
	stamina_tab.set_script(preload("res://src/ui/debug/debug_stamina_gui.gd"))
	stamina_tab.name = "Stamina"
	_tab_container.add_child(stamina_tab)
	stamina_tab.setup(player.stamina_component)

	if ball != null:
		var ball_tab: Control = Control.new()
		ball_tab.set_script(preload("res://src/ui/debug/debug_ball_gui.gd"))
		ball_tab.name = "Ball Physics"
		_tab_container.add_child(ball_tab)
		ball_tab.setup(ball, player.kick_component)

	var tackle_state: PlayerTackleState = player.state_machine.get_node("TackleState") as PlayerTackleState
	if tackle_state and player.tackle_hitbox_component and player.tackle_hurtbox_component:
		var combat_tab: Control = Control.new()
		combat_tab.set_script(preload("res://src/ui/debug/debug_combat_gui.gd"))
		combat_tab.name = "Combat"
		_tab_container.add_child(combat_tab)
		combat_tab.setup(tackle_state, player.tackle_hitbox_component, player.tackle_hurtbox_component)

	var display_tab: Control = Control.new()
	display_tab.set_script(preload("res://src/ui/debug/debug_display_gui.gd"))
	display_tab.name = "Display"
	_tab_container.add_child(display_tab)
	display_tab.setup(player)

	var opponents: Array[Node] = get_tree().get_nodes_in_group("opponents")
	if opponents.size() > 0:
		var ai_tab: Control = Control.new()
		ai_tab.set_script(preload("res://src/ui/debug/debug_ai_gui.gd"))
		ai_tab.name = "AI"
		_tab_container.add_child(ai_tab)
		ai_tab.setup(opponents[0])
