class_name Turret
extends Node2D
## Torreta: estática, auto-ataca al enemigo más cercano en rango. Stats y color
## desde TurretData. splash_radius > 0 → daño en área (bombardero). Invulnerable.

@export var data: TurretData

var combat := CombatStatsComponent.new()
var _attack_cd: float = 0.0
var _beam_to: Vector2
var _beam_t: float = 0.0

@onready var body: Polygon2D = $Body


func _ready() -> void:
	if data == null:
		push_warning("Turret sin TurretData asignado: %s" % name)
		set_process(false)
		return
	combat.setup(data.stats, [])
	body.color = data.body_color


func _process(delta: float) -> void:
	_attack_cd -= delta
	var nearest := _nearest_in_range()
	if nearest != null and _attack_cd <= 0.0:
		_fire_at(nearest)
		_attack_cd = 1.0 / combat.current.attack_speed
		_beam_to = nearest.aim_point()
		_beam_t = 0.12

	if _beam_t > 0.0:
		_beam_t -= delta
		queue_redraw()


func _fire_at(target: Enemy) -> void:
	var dmg := combat.current.damage
	var pen := combat.current.penetration
	if data.splash_radius > 0.0:
		# daño en área: todos los enemigos cerca del objetivo
		var center := target.aim_point()
		for node in get_tree().get_nodes_in_group("enemies"):
			var e := node as Enemy
			if e != null and center.distance_to(e.aim_point()) <= data.splash_radius:
				e.take_damage(dmg, pen)
	else:
		target.take_damage(dmg, pen)


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
	draw_line(Vector2.ZERO, end, data.body_color, 2.0)
	draw_circle(end, 4.0, Color.WHITE)
