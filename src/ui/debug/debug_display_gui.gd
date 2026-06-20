extends Control

var _player: Player = null

func setup(player: Player) -> void:
	_player = player
	_build_controls()

func _build_controls() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	var header: Label = Label.new()
	header.text = "Display"
	header.add_theme_font_size_override("font_size", 18)
	vbox.add_child(header)

	var checkbox: CheckBox = CheckBox.new()
	checkbox.text = "Show State Label"
	checkbox.button_pressed = false
	vbox.add_child(checkbox)

	checkbox.toggled.connect(func(pressed: bool) -> void:
		_player.set_state_label_visible(pressed)
	)
