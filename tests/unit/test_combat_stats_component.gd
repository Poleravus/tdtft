extends GutTest
## CombatStatsComponent: vida, daño con mitigación y recálculo por modificadores.

func _stats(hp: float, res: float = 0.0) -> CombatStats:
	var s := CombatStats.new()
	s.max_health = hp
	s.resistance = res
	return s


func test_setup_arranca_a_vida_full() -> void:
	var c := CombatStatsComponent.new()
	c.setup(_stats(100.0))
	assert_eq(c.health, 100.0)


func test_take_damage_aplica_mitigacion() -> void:
	var c := CombatStatsComponent.new()
	c.setup(_stats(100.0, 10.0))   # 10% de resistencia
	c.take_damage(10.0, 0.0)        # recibe 9
	assert_almost_eq(c.health, 91.0, 0.001)


func test_muere_a_cero() -> void:
	var c := CombatStatsComponent.new()
	c.setup(_stats(20.0))
	watch_signals(c)
	c.take_damage(999.0, 0.0)
	assert_true(c.is_dead())
	assert_signal_emitted(c, "died")


func test_add_modifier_recalcula_max_health() -> void:
	var c := CombatStatsComponent.new()
	c.setup(_stats(100.0))
	var d := StatDelta.new()
	d.stat = "max_health"
	d.op = StatDelta.Op.FLAT_ADD
	d.value = 50.0
	var m := Modifier.new()
	m.deltas.append(d)
	c.add_modifier(m)
	assert_almost_eq(c.current.max_health, 150.0, 0.001)
