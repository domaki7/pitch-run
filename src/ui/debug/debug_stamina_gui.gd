extends Control

var _component: StaminaComponent = null
var _defaults: Dictionary = {}
var _controls: Dictionary = {}
var _vbox: VBoxContainer = null

func setup(component: StaminaComponent) -> void:
	_component = component
	_store_defaults()
	_build_controls()

func _store_defaults() -> void:
	_defaults = {
		"max_stamina": _component.max_stamina,
		"regen_rate": _component.regen_rate,
		"regen_delay": _component.regen_delay,
		"sprint_drain_rate": _component.sprint_drain_rate,
		"tackle_cost": _component.tackle_cost,
	}

func _build_controls() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	_vbox = VBoxContainer.new()
	_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_vbox)

	_add_header("Stamina")
	_add_float_control("max_stamina", 0.0, 500.0, 5.0)
	_add_float_control("regen_rate", 0.0, 100.0, 1.0)
	_add_float_control("regen_delay", 0.0, 5.0, 0.1)
	_add_float_control("sprint_drain_rate", 0.0, 100.0, 1.0)
	_add_float_control("tackle_cost", 0.0, 100.0, 1.0)

	_vbox.add_child(HSeparator.new())
	_add_copy_button()

func _add_header(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	_vbox.add_child(label)

func _add_float_control(property: String, min_val: float, max_val: float, step: float) -> void:
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
	slider.value = _component.get(property)
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
		_component.set(property, value)
		value_label.text = str(snappedf(value, step))
		reset_btn.visible = not is_equal_approx(value, default_val)
		if property == "max_stamina" and _component.current_stamina > value:
			_component.current_stamina = value
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
			var current: float = _component.get(property)
			if not is_equal_approx(current, _defaults[property]):
				changed[property] = current
		DisplayServer.clipboard_set(JSON.stringify(changed, "  "))
	)
