extends Node
## RunManager — fases de la run (PREP ↔ COMBAT) y economía (oro/exp/nivel).
## En PREP el jugador compra/coloca y arranca la ronda (botón "Empezar" o
## auto-timer). La economía vive aquí por simplicidad del MVP.

enum Phase { PREP, COMBAT }

const PREP_TIME: float = 8.0      ## segundos de auto-inicio en preparación
const BASE_INCOME: int = 0        ## income de ronda por ahora = solo interés (+ kills aparte)
const INTEREST_PER: int = 10      ## 1 de interés por cada 10 de oro guardado
const INTEREST_CAP: int = 5
const XP_PER_KILL: int = 1
const XP_PER_ROUND: int = 2

var phase: int = Phase.PREP
var auto_start: bool = true

var _run_active: bool = false
var _round_pending: bool = false
var _prep_timer: Timer


func _ready() -> void:
	_prep_timer = Timer.new()
	_prep_timer.one_shot = true
	_prep_timer.timeout.connect(_on_prep_timeout)
	add_child(_prep_timer)

	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.wave_cleared.connect(_on_wave_cleared)
	EventBus.run_ended.connect(_on_run_ended)


func start_run() -> void:
	GameState.reset()
	_run_active = true
	EventBus.run_started.emit()
	_enter_prep()


## Botón "Empezar": arranca la ronda de inmediato.
func request_start_round() -> void:
	if _run_active and _round_pending and phase == Phase.PREP:
		_prep_timer.stop()
		_start_round()


## Toggle de auto-inicio (afecta también la preparación en curso).
func set_auto_start(on: bool) -> void:
	auto_start = on
	if not _run_active or phase != Phase.PREP or not _round_pending:
		return
	if on and _prep_timer.is_stopped():
		_prep_timer.start(PREP_TIME)
	elif not on:
		_prep_timer.stop()


func can_afford(amount: int) -> bool:
	return GameState.gold >= amount


func spend_gold(amount: int) -> bool:
	if GameState.gold < amount:
		return false
	GameState.gold -= amount
	EventBus.gold_changed.emit(GameState.gold)
	return true


func _enter_prep() -> void:
	if not _run_active:
		return
	phase = Phase.PREP
	_round_pending = true
	EventBus.phase_changed.emit(phase)
	if auto_start:
		_prep_timer.start(PREP_TIME)


func _on_prep_timeout() -> void:
	if _run_active and _round_pending and phase == Phase.PREP and auto_start:
		_start_round()


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
	_add_gold(bounty)
	_add_xp(XP_PER_KILL)


func _award_round_income() -> void:
	var castle_gold: int = int(GameState.castle.passive_gold) if GameState.castle != null else 0
	_add_gold(BASE_INCOME + interest_for(GameState.gold) + castle_gold)
	_add_xp(XP_PER_ROUND)


func _add_gold(amount: int) -> void:
	if amount <= 0:
		return
	GameState.gold += amount
	EventBus.gold_changed.emit(GameState.gold)


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
	_prep_timer.stop()


# --- Helpers puros (testeables) ---
static func interest_for(gold: int) -> int:
	return mini(gold / INTEREST_PER, INTEREST_CAP)


static func xp_needed(level: int) -> int:
	return level * 5
