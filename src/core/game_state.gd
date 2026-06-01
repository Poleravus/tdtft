extends Node
## GameState — fuente única de verdad del estado de la run en curso.
## Muta aquí y notifica vía EventBus; UI y sistemas reaccionan sin acoplarse.

# --- Identidad de la run ---
var hero: Hero                                ## actor Hero instanciado
var universe: Universe
var castle: CastleData
var selected_hero: HeroData                   ## héroe elegido en el menú (persiste entre niveles)

# --- Progreso / fase ---
var round_number: int = 0
var elapsed_time: float = 0.0
var difficulty: int = 1

# --- Economía / nivel ---
var gold: int = 0
var exp: int = 0
var level: int = 1                            ## 1..ShopConfig.max_level
var base_hp: int = 0
var base_hp_max: int = 0
var active_augments: Array[Augment] = []

# --- Combate ---
var alive_enemies: int = 0

# --- Autochess (tienda / banca / tablero) ---
var shop_config: ShopConfig
var shop_offer: Array = []                    ## TurretData en tienda (tam = shop_config.shop_size)
var shop_locked: bool = false                 ## congelar tienda entre rondas
var bench: Array = []                          ## unidades compradas sin colocar
var board: Array = []                          ## unidades colocadas defendiendo
var pool_remaining: Dictionary = {}            ## TurretData -> copias restantes (escasez)


## Slots de tablero disponibles = base por nivel + bonus del castillo.
func board_capacity() -> int:
	if shop_config == null:
		return level
	var slots := shop_config.board_slots_by_level
	var i := clampi(level - 1, 0, slots.size() - 1)
	var bonus: int = castle.board_slot_bonus if castle != null else 0
	return slots[i] + bonus


## Reiniciar el estado mutable al empezar una run nueva.
func reset() -> void:
	round_number = 0
	elapsed_time = 0.0
	gold = 0
	exp = 0
	level = 1
	active_augments.clear()
	alive_enemies = 0
	shop_offer.clear()
	shop_locked = false
	bench.clear()
	board.clear()
	pool_remaining.clear()
