extends Control

var _opponent: Node2D = null
var _chase_state: OpponentChaseState = null
var _tackle_state: OpponentTackleState = null
var _dribble_state: OpponentDribbleState = null
var _return_state: OpponentReturnToPositionState = null
var _movement: MovementComponent = null
var _stamina: StaminaComponent = null
var _hitbox: TackleHitboxComponent = null
var _hurtbox: TackleHurtboxComponent = null
var _defaults: Dictionary = {}
var _controls: Dictionary = {}
var _vbox: VBoxContainer = null

func setup(opponent_node: Node2D) -> void:
	_opponent = opponent_node
	_chase_state = opponent_node.state_machine.get_node("ChaseState") as OpponentChaseState
	_tackle_state = opponent_node.state_machine.get_node("TackleState") as OpponentTackleState
	_dribble_state = opponent_node.state_machine.get_node("DribbleState") as OpponentDribbleState
	_return_state = opponent_node.state_machine.get_node("ReturnToPositionState") as OpponentReturnToPositionState
	_movement = opponent_node.movement_component
	_stamina = opponent_node.stamina_component
	_hitbox = opponent_node.tackle_hitbox_component
	_hurtbox = opponent_node.tackle_hurtbox_component
	_store_defaults()
	_build_controls()

func _store_defaults() -> void:
	_defaults = {
		"tackle_range": _chase_state.tackle_range,
		"shoot_range": _dribble_state.shoot_range,
		"lunge_distance": _tackle_state.lunge_distance,
		"lunge_duration": _tackle_state.lunge_duration,
		"cooldown_duration": _tackle_state.cooldown_duration,
		"ball_pop_force": _tackle_state.ball_pop_force,
		"ball_pop_bias": _tackle_state.ball_pop_bias,
		"arrival_threshold": _return_state.arrival_threshold,
		"interrupt_chase_distance": _return_state.interrupt_chase_distance,
		"speed": _movement.speed,
		"acceleration": _movement.acceleration,
		"friction": _movement.friction,
		"max_stamina": _stamina.max_stamina,
		"tackle_cost": _stamina.tackle_cost,
	}

func _build_controls() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	_vbox = VBoxContainer.new()
	_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_vbox)

	_add_header("Chase")
	_add_float_control(_chase_state, "tackle_range", 10.0, 200.0, 5.0)

	_add_header("Dribble")
	_add_float_control(_dribble_state, "shoot_range", 50.0, 800.0, 10.0)

	_add_header("Tackle")
	_add_float_control(_tackle_state, "lunge_distance", 10.0, 300.0, 5.0)
	_add_float_control(_tackle_state, "lunge_duration", 0.05, 1.0, 0.05)
	_add_float_control(_tackle_state, "cooldown_duration", 0.1, 3.0, 0.1)
	_add_float_control(_tackle_state, "ball_pop_force", 0.0, 500.0, 10.0)
	_add_float_control(_tackle_state, "ball_pop_bias", 0.0, 1.0, 0.05)

	_add_header("Return")
	_add_float_control(_return_state, "arrival_threshold", 5.0, 100.0, 5.0)
	_add_float_control(_return_state, "interrupt_chase_distance", 50.0, 500.0, 10.0)

	_add_header("Movement")
	_add_float_control(_movement, "speed", 0.0, 1000.0, 1.0)
	_add_float_control(_movement, "acceleration", 0.0, 50.0, 0.5)
	_add_float_control(_movement, "friction", 0.0, 50.0, 0.5)

	_add_header("Stamina")
	_add_float_control(_stamina, "max_stamina", 0.0, 500.0, 5.0)
	_add_float_control(_stamina, "tackle_cost", 0.0, 100.0, 1.0)

	_vbox.add_child(HSeparator.new())

	_add_header("Visualization")
	_add_checkbox_control("Show State Label", func(pressed: bool) -> void:
		_opponent.set_state_label_visible(pressed)
	)
	_add_checkbox_control("Show Tackle Hitbox", func(pressed: bool) -> void:
		_hitbox.debug_draw = pressed
		_hitbox.queue_redraw()
	)
	_add_checkbox_control("Show Tackle Hurtbox", func(pressed: bool) -> void:
		_hurtbox.debug_draw = pressed
		_hurtbox.queue_redraw()
	)

	_vbox.add_child(HSeparator.new())
	_add_copy_button()

func _add_header(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	_vbox.add_child(label)

func _add_float_control(target: Object, property: String, min_val: float, max_val: float, step: float) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	_vbox.add_child(row)

	var label: Label = Label.new()
	label.text = property.capitalize()
	label.custom_minimum_size.x = 160.0
	row.add_child(label)

	var slider: HSlider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = step
	slider.value = target.get(property)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)

	var value_label: Label = Label.new()
	value_label.text = str(snappedf(slider.value, step))
	value_label.custom_minimum_size.x = 60.0
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value_label)

	var reset_btn: Button = Button.new()
	reset_btn.text = "Reset"
	reset_btn.visible = false
	row.add_child(reset_btn)

	var default_val: float = _defaults[property]

	slider.value_changed.connect(func(value: float) -> void:
		target.set(property, value)
		value_label.text = str(snappedf(value, step))
		reset_btn.visible = not is_equal_approx(value, default_val)
	)

	reset_btn.pressed.connect(func() -> void:
		slider.value = default_val
	)

	_controls[property] = {"slider": slider, "value_label": value_label, "reset_button": reset_btn}

func _add_checkbox_control(label_text: String, callback: Callable) -> void:
	var checkbox: CheckBox = CheckBox.new()
	checkbox.text = label_text
	checkbox.toggled.connect(callback)
	_vbox.add_child(checkbox)

func _add_copy_button() -> void:
	var btn: Button = Button.new()
	btn.text = "Copy Values to Clipboard"
	_vbox.add_child(btn)

	btn.pressed.connect(func() -> void:
		var changed: Dictionary = {}
		for property: String in _defaults:
			var target: Object = _get_target_for_property(property)
			var current: float = target.get(property)
			if not is_equal_approx(current, _defaults[property]):
				changed[property] = current
		DisplayServer.clipboard_set(JSON.stringify(changed, "  "))
	)

func _get_target_for_property(property: String) -> Object:
	if property == "tackle_range":
		return _chase_state
	elif property == "shoot_range":
		return _dribble_state
	elif property in ["lunge_distance", "lunge_duration", "cooldown_duration", "ball_pop_force", "ball_pop_bias"]:
		return _tackle_state
	elif property in ["arrival_threshold", "interrupt_chase_distance"]:
		return _return_state
	elif property in ["speed", "acceleration", "friction"]:
		return _movement
	else:
		return _stamina
