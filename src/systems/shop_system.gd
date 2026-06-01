class_name ShopSystem
extends RefCounted
## Motor de la tienda autochess: tira N unidades según las odds del nivel desde
## un pool finito, comprar (descuenta del pool) y reroll. Sin estado de UI.
## El pool solo baja al COMPRAR (la oferta es una "vista", como en TFT).

var config: ShopConfig
var units: Array = []                ## catálogo de TurretData comprables
var pool: Dictionary = {}            ## TurretData -> copias restantes
var _by_rarity: Dictionary = {}      ## rareza (int) -> Array[TurretData]
var _rng := RandomNumberGenerator.new()


func setup(p_config: ShopConfig, p_units: Array) -> void:
	config = p_config
	units = p_units
	_rng.randomize()
	pool.clear()
	_by_rarity.clear()
	for u in units:
		pool[u] = _pool_size(u.rarity)
		if not _by_rarity.has(u.rarity):
			_by_rarity[u.rarity] = []
		_by_rarity[u.rarity].append(u)


## Costo por rareza: común 1 … legendaria 4.
func unit_cost(unit: TurretData) -> int:
	return unit.rarity + 1


## Oro al vender una unidad: su costo de construcción (costo × 3^(estrella-1))
## menos 1; mínimo 1. Así una 2★ (3 copias) vale ~3×, una 3★ ~9×.
static func sell_value(cost: int, star: int) -> int:
	return maxi(1, cost * int(pow(3, star - 1)) - 1)


## Tira la oferta (shop_size slots) según las odds del nivel. Puede traer nulls
## si una rareza no tiene unidades disponibles (slot vacío).
func roll(level: int) -> Array:
	var offer: Array = []
	var odds := _odds_for(level)
	for i in config.shop_size:
		offer.append(_pick_unit(odds))
	return offer


## Compra: descuenta del pool. False si ya no quedaban copias.
func buy(unit: TurretData) -> bool:
	if unit == null or pool.get(unit, 0) <= 0:
		return false
	pool[unit] -= 1
	return true


func _pool_size(rarity: int) -> int:
	return config.pool_per_unit[rarity] if rarity < config.pool_per_unit.size() else 0


func _odds_for(level: int) -> PackedFloat32Array:
	var i := clampi(level - 1, 0, config.odds_by_level.size() - 1)
	return config.odds_by_level[i]


func _pick_unit(odds: PackedFloat32Array) -> TurretData:
	var r := _rng.randf()
	var acc := 0.0
	var chosen := odds.size() - 1
	for rarity in odds.size():
		acc += odds[rarity]
		if r <= acc:
			chosen = rarity
			break
	# si la rareza elegida no tiene unidades disponibles, baja a una menor
	# (evita slots vacíos cuando una rareza —ej. legendaria— aún no tiene unidades)
	for rarity in range(chosen, -1, -1):
		var u := _random_available(rarity)
		if u != null:
			return u
	return null


func _random_available(rarity: int) -> TurretData:
	if not _by_rarity.has(rarity):
		return null
	var avail: Array = []
	for u in _by_rarity[rarity]:
		if pool.get(u, 0) > 0:
			avail.append(u)
	if avail.is_empty():
		return null
	return avail[_rng.randi() % avail.size()]
