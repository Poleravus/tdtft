extends GutTest
## Tests de GameState.board_capacity() — slots de tablero = base por nivel
## (de ShopConfig) + bonus del castillo. Se prueba sobre una instancia fresca
## del script para no tocar el autoload global.

const GameStateScript := preload("res://src/core/game_state.gd")

var _gs


func before_each() -> void:
	_gs = GameStateScript.new()


func after_each() -> void:
	_gs.free()


func test_sin_config_cae_al_nivel() -> void:
	_gs.shop_config = null
	_gs.level = 5
	assert_eq(_gs.board_capacity(), 5)


func test_usa_la_tabla_por_nivel() -> void:
	_gs.shop_config = ShopConfig.new()
	_gs.castle = null
	_gs.level = 3
	assert_eq(_gs.board_capacity(), 3)  # board_slots_by_level[2] = 3


func test_suma_el_bonus_del_castillo() -> void:
	var castle := CastleData.new()
	castle.board_slot_bonus = 2
	_gs.shop_config = ShopConfig.new()
	_gs.castle = castle
	_gs.level = 1
	assert_eq(_gs.board_capacity(), 3)  # slots[0]=1 + bonus 2


func test_clampa_nivel_fuera_de_rango() -> void:
	_gs.shop_config = ShopConfig.new()
	_gs.castle = null
	_gs.level = 99
	assert_eq(_gs.board_capacity(), 12)  # se topa en el último slot
