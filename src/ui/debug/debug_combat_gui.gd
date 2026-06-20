extends Control

var _tackle_state: PlayerTackleState = null
var _hitbox: TackleHitboxComponent = null
var _hurtbox: TackleHurtboxComponent = null
var _defaults: Dictionary = {}
var _controls: Dictionary = {}
var _vbox: VBoxContainer = null

func setup(tackle_state: PlayerTackleState, hitbox: TackleHitboxComponent, hurtbox: TackleHurtboxComponent) -> void:
	_tackle_state = tackle_state
	_hitbox = hitbox
	_hurtbox = hurtbox
	_store_defaults()
	_build_controls()

func _store_defaults() -> void:
	_defaults = {
		"lunge_distance": _tackle_state.lunge_distance,
		"lunge_duration": _tackle_state.lunge_duration,
		"cooldown_duration": _tackle_state.cooldown_duration,
		"ball_pop_force": _tackle_state.ball_pop_force,
		"ball_pop_bias": _tackle_state.ball_pop_bias,
		"hitbox_offset": _hitbox.hitbox_offset,
		"hitbox_width": _hitbox.hitbox_width,
		"hitbox_height": _hitbox.hitbox_height,
		"hurtbox_radius": _hurtbox.hurtbox_radius,
	}

func _build_controls() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	_vbox = VBoxContainer.new()
	_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_vbox)

	_add_header("Lunge")
	_add_float_control(_tackle_state, "lunge_distance", 10.0, 300.0, 5.0)
	_add_float_control(_tackle_state, "lunge_duration", 0.05, 1.0, 0.05)
	_add_float_control(_tackle_state, "cooldown_duration", 0.1, 3.0, 0.1)

	_add_header("Ball Pop")
	_add_float_control(_tackle_state, "ball_pop_force", 0.0, 500.0, 10.0)
	_add_float_control(_tackle_state, "ball_pop_bias", 0.0, 1.0, 0.05)

	_add_header("Hitbox Shape")
	_add_float_control(_hitbox, "hitbox_offset", 0.0, 60.0, 1.0)
	_add_float_control(_hitbox, "hitbox_width", 4.0, 60.0, 1.0)
	_add_float_control(_hitbox, "hitbox_height", 4.0, 60.0, 1.0)

	_add_header("Hurtbox Shape")
	_add_float_control(_hurtbox, "hurtbox_radius", 4.0, 40.0, 1.0)

	_vbox.add_child(HSeparator.new())

	_add_header("Visualization")
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
	label.custom_minimum_size.x = 120.0
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
	if property in ["hitbox_offset", "hitbox_width", "hitbox_height"]:
		return _hitbox
	elif property == "hurtbox_radius":
		return _hurtbox
	else:
		return _tackle_state
