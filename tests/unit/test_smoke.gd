extends GutTest
## Smoke: fuerza el parseo de scripts que GUT no carga solo (escenas/entidades),
## para cachar errores de sintaxis sin tener que abrir el editor.

func test_scripts_parsean() -> void:
	assert_not_null(preload("res://scenes/Cristian1.gd"), "Cristian1 parsea")
	assert_not_null(preload("res://src/entities/Torretas/turret.gd"), "Turret parsea")
	assert_not_null(preload("res://src/entities/Hero/Hero.gd"), "Hero parsea")
	assert_not_null(preload("res://src/entities/Enemigos/enemy.gd"), "Enemy parsea")
	assert_not_null(preload("res://src/entities/Enemigos/Slime.gd"), "Slime parsea")
	assert_not_null(preload("res://src/entities/Castle/Castle.gd"), "Castle parsea")
