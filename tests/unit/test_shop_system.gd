extends GutTest
## Motor de la tienda: tirada por odds del nivel y compra desde el pool.
## ShopSystem se precarga (clase nueva de la sesión; el caché global de clases
## la registra al abrir el editor).

const ShopSystemScript := preload("res://src/systems/shop_system.gd")


func _unit(rarity: int) -> TurretData:
	var u := TurretData.new()
	u.rarity = rarity
	u.stats = CombatStats.new()
	return u


func test_nivel_1_solo_tira_comunes() -> void:
	var shop = ShopSystemScript.new()
	var comun := _unit(Rarity.Tier.COMUN)
	var rara := _unit(Rarity.Tier.RARA)
	shop.setup(ShopConfig.new(), [comun, rara])
	for u in shop.roll(1):   # nivel 1 -> odds 100% común
		assert_eq(u, comun)


func test_comprar_descuenta_del_pool() -> void:
	var shop = ShopSystemScript.new()
	var comun := _unit(Rarity.Tier.COMUN)
	shop.setup(ShopConfig.new(), [comun])
	var antes: int = shop.pool[comun]
	assert_true(shop.buy(comun))
	assert_eq(shop.pool[comun], antes - 1)


func test_costo_por_rareza() -> void:
	var shop = ShopSystemScript.new()
	shop.setup(ShopConfig.new(), [])
	assert_eq(shop.unit_cost(_unit(Rarity.Tier.COMUN)), 1)
	assert_eq(shop.unit_cost(_unit(Rarity.Tier.EPICA)), 3)


func test_valor_de_venta_por_estrella() -> void:
	assert_eq(ShopSystemScript.sell_value(1, 1), 1)    # max(1, 1-1) = 1
	assert_eq(ShopSystemScript.sell_value(2, 1), 1)    # 2-1 = 1
	assert_eq(ShopSystemScript.sell_value(2, 2), 5)    # 2*3 - 1 = 5
	assert_eq(ShopSystemScript.sell_value(3, 3), 26)   # 3*9 - 1 = 26
