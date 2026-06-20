class_name StaminaComponent
extends Node

signal stamina_changed(current: float, maximum: float)
signal stamina_depleted

@export_group("Stamina")
@export var max_stamina: float = 100.0
@export var regen_rate: float = 15.0
@export var regen_delay: float = 1.0
@export var sprint_drain_rate: float = 20.0
@export var tackle_cost: float = 15.0

var current_stamina: float = 0.0
var is_sprinting: bool = false
var _regen_timer: float = 0.0

func _ready() -> void:
	current_stamina = max_stamina

func _physics_process(delta: float) -> void:
	if is_sprinting:
		_drain(sprint_drain_rate * delta)
		_regen_timer = regen_delay
	else:
		if _regen_timer > 0.0:
			_regen_timer -= delta
		elif current_stamina < max_stamina:
			_regen(regen_rate * delta)

func start_sprint() -> bool:
	if current_stamina > 0.0:
		is_sprinting = true
		return true
	return false

func stop_sprint() -> void:
	is_sprinting = false

func use_stamina(amount: float) -> bool:
	if current_stamina >= amount:
		_drain(amount)
		return true
	return false

func _drain(amount: float) -> void:
	current_stamina = maxf(0.0, current_stamina - amount)
	stamina_changed.emit(current_stamina, max_stamina)
	if current_stamina <= 0.0:
		is_sprinting = false
		stamina_depleted.emit()

func _regen(amount: float) -> void:
	current_stamina = minf(max_stamina, current_stamina + amount)
	stamina_changed.emit(current_stamina, max_stamina)
