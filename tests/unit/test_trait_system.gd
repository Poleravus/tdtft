extends GutTest
## TraitSystem.count_tags: cuenta rasgos de un conjunto de unidades.

const TraitSystemScript := preload("res://src/systems/trait_system.gd")


func _unit(tags: Array) -> TurretData:
	var u := TurretData.new()
	for t in tags:
		u.trait_tags.append(t)
	return u


func test_cuenta_los_rasgos() -> void:
	var counts = TraitSystemScript.count_tags([
		_unit(["Arquero", "Oscuro"]),
		_unit(["Arquero", "Claro"]),
		_unit(["Guerrero", "Oscuro"]),
	])
	assert_eq(counts["Arquero"], 2)
	assert_eq(counts["Oscuro"], 2)
	assert_eq(counts["Guerrero"], 1)
	assert_eq(counts["Claro"], 1)


func test_vacio_no_cuenta() -> void:
	assert_eq(TraitSystemScript.count_tags([]).size(), 0)
