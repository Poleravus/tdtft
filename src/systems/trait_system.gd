class_name TraitSystem
## Cuenta los rasgos (tags) de un conjunto de unidades para el panel de
## sinergias. Por ahora solo cuenta — los bonus por umbral vienen con el diseño.

## Devuelve {tag: cantidad} a partir de una lista de TurretData.
static func count_tags(units: Array) -> Dictionary:
	var counts := {}
	for u in units:
		for tag in u.trait_tags:
			counts[tag] = counts.get(tag, 0) + 1
	return counts
