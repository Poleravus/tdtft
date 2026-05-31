extends Node
## RunManager — fases de la run (PREP ↔ COMBAT) y economía (oro/exp/nivel).
## La ronda arranca SOLO al pulsar "Empezar" (sin auto-inicio). La economía
## vive aquí por simplicidad del MVP.

enum Phase { PREP, COMBAT }

const STARTING_GOLD: int = 4
const BASE_INCOME: int = 0        ## income de ronda = solo interés (+ kills aparte)
const INTEREST_PER: int = 10
const INTEREST_CAP: int = 5
const XP_PER_ROUND: int = 2
const XP_COST: int = 4            ## comprar XP en la tienda
const XP_BUY_AMOUNT: int = 4

var phase: int = Phase.PREP

var _run_active: bool = false
var _round_pending: bool = false


func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.wave_cleared.connect(_on_wave_cleared)
	EventBus.run_ended.connect(_on_run_ended)


func start_run() -> void:
	GameState.reset()
	GameState.gold = STARTING_GOLD
	_run_active = true
	EventBus.run_started.emit()
	EventBus.gold_changed.emit(GameState.gold)
	_enter_prep()


## Botón "Empezar": única forma de pasar a combate.
func request_start_round() -> void:
	if _run_active and _round_pending and phase == Phase.PREP:
		_start_round()


func can_afford(amount: int) -> bool:
	return GameState.gold >= amount


func spend_gold(amount: int) -> bool:
	if GameState.gold < amount:
		return false
	GameState.gold -= amount
	EventBus.gold_changed.emit(GameState.gold)
	return true


## Suma oro (recompensas de kills, income, venta de unidades).
func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	GameState.gold += amount
	EventBus.gold_changed.emit(GameState.gold)


func buy_xp() -> bool:
	if not spend_gold(XP_COST):
		return false
	_add_xp(XP_BUY_AMOUNT)
	return true


func is_max_level() -> bool:
	return GameState.level >= _max_level()


func _enter_prep() -> void:
	if not _run_active:
		return
	phase = Phase.PREP
	_round_pending = true
	EventBus.phase_changed.emit(phase)


func _start_round() -> void:
	_round_pending = false
	GameState.round_number += 1
	phase = Phase.COMBAT
	EventBus.phase_changed.emit(phase)
	EventBus.round_started.emit(GameState.round_number)


func _on_wave_cleared(_round_number: int) -> void:
	if not _run_active:
		return
	EventBus.round_ended.emit(GameState.round_number)
	_award_round_income()
	_enter_prep()


func _on_enemy_died(_enemy: Node, bounty: int) -> void:
	add_gold(bounty)  # los kills dan solo oro; la XP viene de rondas y de comprar XP


func _award_round_income() -> void:
	var castle_gold: int = int(GameState.castle.passive_gold) if GameState.castle != null else 0
	add_gold(BASE_INCOME + interest_for(GameState.gold) + castle_gold)
	_add_xp(XP_PER_ROUND)


func _add_xp(amount: int) -> void:
	GameState.exp += amount
	var max_level := _max_level()
	while GameState.level < max_level and GameState.exp >= xp_needed(GameState.level):
		GameState.exp -= xp_needed(GameState.level)
		GameState.level += 1
		EventBus.level_changed.emit(GameState.level)
	EventBus.exp_changed.emit(GameState.exp)


func _max_level() -> int:
	return GameState.shop_config.max_level if GameState.shop_config != null else 12


func _on_run_ended(_victory: bool) -> void:
	_run_active = false


# --- Helpers puros (testeables) ---
static func interest_for(gold: int) -> int:
	return mini(gold / INTEREST_PER, INTEREST_CAP)


## XP necesaria para pasar del nivel dado al siguiente (curva nivel² × 2).
static func xp_needed(level: int) -> int:
	return level * level * 2
