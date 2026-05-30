extends GutTest
## Helpers puros de economía de RunManager.

func test_interes_escala_y_se_topa() -> void:
	assert_eq(RunManager.interest_for(0), 0)
	assert_eq(RunManager.interest_for(25), 2)    # 25/10 = 2
	assert_eq(RunManager.interest_for(50), 5)    # 50/10 = 5 (justo en el tope)
	assert_eq(RunManager.interest_for(100), 5)   # topado en 5


func test_xp_necesaria_sube_con_nivel() -> void:
	assert_eq(RunManager.xp_needed(1), 5)
	assert_eq(RunManager.xp_needed(4), 20)
