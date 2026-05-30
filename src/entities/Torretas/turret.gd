class_name Turret
extends Node2D
## Torreta (arquero): estática, auto-ataca al enemigo más cercano en rango.
## Stats desde TurretData (vía CombatStatsComponent). Invulnerable por ahora.

@export var data: TurretData

var combat := CombatStatsComponent.new()
var _attack_cd: float = 0.0
var _beam_to: Vector2
var _beam_t: float = 0.0


func _ready() -> void:
	if data == null:
		push_warning("Turret sin TurretData asignado: %s" % name)
		set_process(false)
		return
	combat.setup(data.stats, [])


func _process(delta: float) -> void:
	_attack_cd -= delta
	var nearest := _nearest_in_range()
	if nearest != null and _attack_cd <= 0.0:
		nearest.take_damage(combat.current.damage, combat.current.penetration)
		_attack_cd = 1.0 / combat.current.attack_speed
		_beam_to = nearest.aim_point()
		_beam_t = 0.12

	if _beam_t > 0.0:
		_beam_t -= delta
		queue_redraw()


func _nearest_in_range() -> Enemy:
	var best: Enemy = null
	var best_d := combat.current.attack_range
	for node in get_tree().get_nodes_in_group("enemies"):
		var e := node as Enemy
		if e == null:
			continue
		var d := global_position.distance_to(e.aim_point())
		if d <= best_d:
			best_d = d
			best = e
	return best


func _draw() -> void:
	if _beam_t <= 0.0:
		return
	var end := to_local(_beam_to)
	draw_line(Vector2.ZERO, end, Color(0.4, 1.0, 0.4), 2.0)
	draw_circle(end, 4.0, Color.WHITE)
