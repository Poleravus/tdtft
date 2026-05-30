extends GutTest
## StatsResolver.resolve(): orden (base + planos) * (1 + %aditivos) * Π(1 + %mult).

func _stats(dmg: float) -> CombatStats:
	var s := CombatStats.new()
	s.damage = dmg
	return s


func _mod(op: StatDelta.Op, value: float, stat: String = "damage") -> Modifier:
	var d := StatDelta.new()
	d.stat = stat
	d.op = op
	d.value = value
	var m := Modifier.new()
	m.deltas.append(d)
	return m


func test_sin_modificadores_devuelve_base() -> void:
	var r := StatsResolver.resolve(_stats(10.0), [])
	assert_almost_eq(r.damage, 10.0, 0.001)


func test_flat_add() -> void:
	var r := StatsResolver.resolve(_stats(10.0), [_mod(StatDelta.Op.FLAT_ADD, 5.0)])
	assert_almost_eq(r.damage, 15.0, 0.001)


func test_percent_add() -> void:
	var r := StatsResolver.resolve(_stats(10.0), [_mod(StatDelta.Op.PERCENT_ADD, 0.5)])
	assert_almost_eq(r.damage, 15.0, 0.001)


func test_percent_mult_se_multiplica() -> void:
	var mods := [_mod(StatDelta.Op.PERCENT_MULT, 0.2), _mod(StatDelta.Op.PERCENT_MULT, 0.2)]
	var r := StatsResolver.resolve(_stats(10.0), mods)
	assert_almost_eq(r.damage, 14.4, 0.001)  # 10 * 1.2 * 1.2


func test_orden_combinado() -> void:
	var mods := [
		_mod(StatDelta.Op.FLAT_ADD, 5.0),
		_mod(StatDelta.Op.PERCENT_ADD, 0.5),
		_mod(StatDelta.Op.PERCENT_MULT, 0.2),
	]
	var r := StatsResolver.resolve(_stats(10.0), mods)
	assert_almost_eq(r.damage, 27.0, 0.001)  # (10+5) * 1.5 * 1.2


func test_no_toca_stats_sin_delta() -> void:
	var s := _stats(10.0)
	s.attack_range = 64.0
	var r := StatsResolver.resolve(s, [_mod(StatDelta.Op.FLAT_ADD, 5.0)])
	assert_almost_eq(r.attack_range, 64.0, 0.001)  # intacto
