extends Control

var _component: MovementComponent = null
var _defaults: Dictionary = {}
var _controls: Dictionary = {}
var _vbox: VBoxContainer = null

func setup(component: MovementComponent) -> void:
	_component = component
	_store_defaults()
	_build_controls()

func _store_defaults() -> void:
	_defaults = {
		"speed": _component.speed,
		"acceleration": _component.acceleration,
		"friction": _component.friction,
		"sprint_multiplier": _component.sprint_multiplier,
	}

func _build_controls() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	_vbox = VBoxContainer.new()
	_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_vbox)

	_add_header("Movement")
	_add_float_control("speed", 0.0, 1000.0, 1.0)
	_add_float_control("acceleration", 0.0, 50.0, 0.5)
	_add_float_control("friction", 0.0, 50.0, 0.5)
	_add_float_control("sprint_multiplier", 1.0, 5.0, 0.1)

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
