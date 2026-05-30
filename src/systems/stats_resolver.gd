class_name StatsResolver
## Resuelve los stats ACTUALES a partir de unos stats base y una lista de
## modificadores. No es un "sistema" con señales: es una utilidad pura
## (sin estado, fácil de testear) que usan las entidades.
##
## Orden de aplicación por stat:
##   (base + planos) * (1 + suma de %aditivos) * Π(1 + cada %multiplicativo)

static func resolve(base: CombatStats, modifiers: Array) -> CombatStats:
	var result: CombatStats = base.duplicate()
	if modifiers.is_empty():
		return result

	var flat := {}      # stat -> suma de FLAT_ADD
	var pct_add := {}    # stat -> suma de PERCENT_ADD
	var pct_mul := {}    # stat -> producto de (1 + PERCENT_MULT)
	for mod in modifiers:
		if mod == null:
			continue
		for d in mod.deltas:
			match d.op:
				StatDelta.Op.FLAT_ADD:
					flat[d.stat] = flat.get(d.stat, 0.0) + d.value
				StatDelta.Op.PERCENT_ADD:
					pct_add[d.stat] = pct_add.get(d.stat, 0.0) + d.value
				StatDelta.Op.PERCENT_MULT:
					pct_mul[d.stat] = pct_mul.get(d.stat, 1.0) * (1.0 + d.value)

	# stats tocados por algún delta (los demás quedan en su valor base)
	var touched := {}
	for k in flat:
		touched[k] = true
	for k in pct_add:
		touched[k] = true
	for k in pct_mul:
		touched[k] = true

	for stat in touched:
		var base_value = base.get(stat)
		if base_value == null:
			push_warning("StatDelta apunta a un stat inexistente en CombatStats: '%s'" % stat)
			continue
		var b: float = base_value
		var v: float = (b + flat.get(stat, 0.0)) * (1.0 + pct_add.get(stat, 0.0)) * pct_mul.get(stat, 1.0)
		result.set(stat, v)

	return result
