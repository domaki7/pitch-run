extends Control

var _ball: Ball = null
var _kick: KickComponent = null
var _defaults: Dictionary = {}
var _controls: Dictionary = {}
var _vbox: VBoxContainer = null

func setup(ball: Ball, kick: KickComponent) -> void:
	_ball = ball
	_kick = kick
	_store_defaults()
	_build_controls()

func _store_defaults() -> void:
	_defaults = {
		"ball_linear_damp": _ball.ball_linear_damp,
		"free_speed_threshold": _ball.free_speed_threshold,
		"ball_angular_damp": _ball.ball_angular_damp,
		"ball_bounce": _ball.ball_bounce,
		"ball_friction": _ball.ball_friction,
		"pass_force": _kick.pass_force,
		"shot_force": _kick.shot_force,
	}

func _build_controls() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	_vbox = VBoxContainer.new()
	_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_vbox)

	_add_header("Ball Physics")
	_add_float_control("ball_linear_damp", 0.0, 20.0, 0.1, _ball)
	_add_float_control("free_speed_threshold", 0.0, 100.0, 1.0, _ball)
	_add_float_control("ball_angular_damp", 0.0, 10.0, 0.1, _ball)
	_add_float_control("ball_bounce", 0.0, 1.0, 0.05, _ball)
	_add_float_control("ball_friction", 0.0, 2.0, 0.05, _ball)

	_add_header("Kick Forces")
	_add_float_control("pass_force", 0.0, 1000.0, 10.0, _kick)
	_add_float_control("shot_force", 0.0, 2000.0, 10.0, _kick)

	_vbox.add_child(HSeparator.new())
	_add_copy_button()

func _add_header(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	_vbox.add_child(label)

func _add_float_control(property: String, min_val: float, max_val: float, step: float, target: Object) -> void:
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
		match property:
			"ball_linear_damp":
				_ball.linear_damp = value
			"ball_angular_damp":
				_ball.angular_damp = value
			"ball_bounce":
				_ball.physics_material_override.bounce = value
			"ball_friction":
				_ball.physics_material_override.friction = value
	)

	reset_btn.pressed.connect(func() -> void:
		slider.value = default_val
	)

	_controls[property] = {"slider": slider, "value_label": value_label, "reset_button": reset_btn}

func _add_copy_button() -> void:
	var btn: Button = Button.new()
	btn.text = "Copy Values to Clipboard"
	_vbox.add_child(btn)

	btn.pressed.connect(func() -> void:
		var changed: Dictionary = {}
		for property: String in _defaults:
			var target: Object = _kick if property in ["pass_force", "shot_force"] else _ball
			var current: float = target.get(property)
			if not is_equal_approx(current, _defaults[property]):
				changed[property] = current
		DisplayServer.clipboard_set(JSON.stringify(changed, "  "))
	)
