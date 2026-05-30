class_name CombatStatsComponent
extends RefCounted
## Estado de combate de un actor (héroe, enemigo, unidad). Composición, no
## herencia: el actor (de cualquier tipo de nodo) posee uno. Resuelve los stats
## base + modificadores, lleva la vida y aplica daño con la fórmula de CombatStats.

signal health_changed(current: float, maximum: float)
signal died

var base_stats: CombatStats
var modifiers: Array[Modifier] = []
var current: CombatStats          ## stats resueltos (base + modificadores)
var health: float = 0.0


func setup(p_base: CombatStats, p_modifiers: Array[Modifier] = []) -> void:
	base_stats = p_base
	modifiers = p_modifiers.duplicate()
	recompute()
	health = current.max_health
	health_changed.emit(health, current.max_health)


func recompute() -> void:
	current = StatsResolver.resolve(base_stats, modifiers)
	if health > current.max_health:
		health = current.max_health


func add_modifier(m: Modifier) -> void:
	if m == null:
		return
	modifiers.append(m)
	recompute()


func take_damage(raw: float, attacker_penetration: float) -> void:
	if health <= 0.0:
		return
	var dmg := CombatStats.mitigate(raw, current.resistance, attacker_penetration)
	health = maxf(0.0, health - dmg)
	health_changed.emit(health, current.max_health)
	if health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	if amount <= 0.0 or health >= current.max_health:
		return
	health = minf(current.max_health, health + amount)
	health_changed.emit(health, current.max_health)


func full_heal() -> void:
	health = current.max_health
	health_changed.emit(health, current.max_health)


func is_dead() -> bool:
	return health <= 0.0
