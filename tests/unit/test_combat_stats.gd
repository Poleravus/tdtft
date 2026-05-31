extends GutTest
## Tests de CombatStats.mitigate() — la fórmula de daño central del juego.
## resist en %, penetración resta resist plano, efectiva topada en [-100, +100].

func test_mitigacion_basica() -> void:
	# 10 de daño contra 10 de resistencia => 9
	assert_almost_eq(CombatStats.mitigate(10.0, 10.0, 0.0), 9.0, 0.001)


func test_sin_resistencia_no_mitiga() -> void:
	assert_almost_eq(CombatStats.mitigate(10.0, 0.0, 0.0), 10.0, 0.001)


func test_resistencia_100_es_inmune() -> void:
	assert_almost_eq(CombatStats.mitigate(10.0, 100.0, 0.0), 0.0, 0.001)


func test_penetracion_resta_resistencia() -> void:
	# resist 50, pen 20 => efectiva 30 => 10 * 0.7 = 7
	assert_almost_eq(CombatStats.mitigate(10.0, 50.0, 20.0), 7.0, 0.001)


func test_penetracion_mayor_que_resistencia_amplifica() -> void:
	# efectiva negativa => recibe MÁS daño. 5 - 25 = -20 => 10 * 1.2 = 12
	assert_almost_eq(CombatStats.mitigate(10.0, 5.0, 25.0), 12.0, 0.001)


func test_efectiva_se_topa_en_menos_100_doble_dano() -> void:
	# con pen enorme la efectiva se clampa en -100 => x2, no más
	assert_almost_eq(CombatStats.mitigate(10.0, 0.0, 999.0), 20.0, 0.001)
