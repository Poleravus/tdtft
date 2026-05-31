extends Node2D
## Controlador del nivel: castillo + héroe, oleadas, HUD y TIENDA (siempre
## disponible): 5 slots por odds/pool, banca (máx 12), reroll, comprar XP,
## colocar sobre el pasto (limitado por slots de tablero = nivel) y vender
## (clic derecho + confirmar) unidades de banca o tablero. La ronda arranca
## solo con "Empezar". RunManager lleva fases/economía; ShopSystem la tienda.

const SlimeScene := preload("res://src/entities/Enemigos/Slime.tscn")
const HeroScene := preload("res://src/entities/Hero/Hero.tscn")
const CastleScene := preload("res://src/entities/Castle/Castle.tscn")
const TurretScene := preload("res://src/entities/Torretas/Turret.tscn")
const ShopSystemScript := preload("res://src/systems/shop_system.gd")
const UNITS := [
	preload("res://resources/turrets/archer.tres"),
	preload("res://resources/turrets/guerrero.tres"),
	preload("res://resources/turrets/mago.tres"),
	preload("res://resources/turrets/bombardero.tres"),
	preload("res://resources/turrets/sniper.tres"),
]

const WAVE_BASE: int = 4
const SPAWN_GAP: float = 0.6
const CASTLE_HP: int = 20
const REROLL_COST: int = 2
const BENCH_SIZE: int = 12

@onready var enemy_path: Path2D = $CaminoEnemigo
@onready var camino: TileMapLayer = $Camino
@onready var mapa: TileMapLayer = $Mapa
@onready var ui: CanvasLayer = $UI
@onready var game_over_label: Label = $UI/GameOverLabel

var _castle: Castle
var _hero: Hero
var _shop                                ## ShopSystem (precargado)
var _shop_offer: Array = []

var _round_label: Label
var _hp_label: Label
var _hero_hp_label: Label
var _gold_label: Label
var _level_label: Label
var _hint_label: Label
var _shop_box: HBoxContainer
var _bench_box: HBoxContainer
var _slot_buttons: Array = []
var _sell_button: Button
var _hide_button: Button

var _alive: int = 0
var _spawning: bool = false
var _wave_active: bool = false

var _placing_unit: TurretData = null
var _board: Dictionary = {}              ## celda (Vector2i) -> Turret colocada
var _sell_pending: Dictionary = {}       ## {} = nada; o {kind, unit, value, turret?}


func _ready() -> void:
	game_over_label.hide()
	GameState.shop_config = ShopConfig.new()
	_shop = ShopSystemScript.new()
	_shop.setup(GameState.shop_config, UNITS)

	_build_hud()
	_build_shop_ui()

	EventBus.base_hp_changed.connect(_on_base_hp_changed)
	EventBus.hero_damaged.connect(_on_hero_damaged)
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.level_changed.connect(_on_progress_changed)
	EventBus.exp_changed.connect(_on_progress_changed)
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.round_started.connect(_on_round_started)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.enemy_reached_castle.connect(_on_enemy_reached_castle)
	EventBus.run_ended.connect(_on_run_ended)

	RunManager.start_run()
	_spawn_castle_and_hero()


func _spawn_castle_and_hero() -> void:
	var curve := enemy_path.curve
	var end_global := enemy_path.to_global(curve.get_point_position(curve.point_count - 1))
	_castle = CastleScene.instantiate()
	_castle.max_health = CASTLE_HP
	add_child(_castle)
	_castle.global_position = end_global
	_hero = HeroScene.instantiate()
	add_child(_hero)
	_hero.global_position = enemy_path.to_global(curve.sample_baked(curve.get_baked_length() * 0.5))


# --- Input en el mundo (colocar / vender torreta del tablero) ---
func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	if get_viewport().gui_get_hovered_control() != null:
		return  # clic sobre la UI: que lo maneje el control
	if _placing_unit != null:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_place(get_global_mouse_position())
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placing()
			get_viewport().set_input_as_handled()
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		var t := _turret_at(get_global_mouse_position())
		if t != null:
			_offer_sell({"kind": "board", "turret": t, "unit": (t as Turret).data,
					"value": _sell_value((t as Turret).data)})
			get_viewport().set_input_as_handled()


func _try_place(world_pos: Vector2) -> void:
	if RunManager.phase != RunManager.Phase.PREP:
		_cancel_placing()
		return
	if _board.size() >= GameState.board_capacity():
		_hint_label.text = "Sin slots de tablero — sube de nivel (Comprar XP)"
		return
	if not _can_build_at(world_pos):
		return
	var cell := mapa.local_to_map(mapa.to_local(world_pos))
	var turret := TurretScene.instantiate()
	turret.data = _placing_unit
	add_child(turret)
	turret.global_position = mapa.to_global(mapa.map_to_local(cell))
	_board[cell] = turret
	GameState.bench.erase(_placing_unit)
	_cancel_placing()
	_refresh_bench()


func _can_build_at(world_pos: Vector2) -> bool:
	var c := camino.local_to_map(camino.to_local(world_pos))
	if camino.get_cell_source_id(c) != -1:
		return false
	var m := mapa.local_to_map(mapa.to_local(world_pos))
	if mapa.get_cell_source_id(m) == -1:
		return false
	return not _board.has(m)


func _cancel_placing() -> void:
	_placing_unit = null
	_hint_label.visible = false


func _turret_at(world_pos: Vector2) -> Node:
	for cell in _board:
		var t = _board[cell]
		if is_instance_valid(t) and world_pos.distance_to(t.global_position) <= 30.0:
			return t
	return null


# --- Vender (clic derecho + confirmar) ---
func _sell_value(unit: TurretData) -> int:
	return maxi(1, _shop.unit_cost(unit) - 1)


func _offer_sell(pending: Dictionary) -> void:
	_sell_pending = pending
	_sell_button.text = "Vender %s (+%d)" % [pending.unit.display_name, pending.value]
	_sell_button.visible = true


func _do_sell() -> void:
	if _sell_pending.is_empty():
		return
	if _sell_pending.kind == "bench":
		GameState.bench.erase(_sell_pending.unit)
		_refresh_bench()
	else:
		var t = _sell_pending.turret
		for cell in _board.keys():
			if _board[cell] == t:
				_board.erase(cell)
				break
		if is_instance_valid(t):
			t.queue_free()
	RunManager.add_gold(_sell_pending.value)
	_cancel_sell()


func _cancel_sell() -> void:
	_sell_pending = {}
	_sell_button.visible = false


# --- Tienda ---
func _roll_shop() -> void:
	_shop_offer = _shop.roll(GameState.level)
	_refresh_shop()


func _on_slot_pressed(i: int) -> void:
	_cancel_sell()
	if i >= _shop_offer.size():
		return
	var unit: TurretData = _shop_offer[i]
	if unit == null:
		return
	if GameState.bench.size() >= BENCH_SIZE:
		_hint_label.text = "Banca llena (máx %d)" % BENCH_SIZE
		_hint_label.visible = true
		return
	var cost: int = _shop.unit_cost(unit)
	if not RunManager.can_afford(cost) or not _shop.buy(unit):
		return
	RunManager.spend_gold(cost)
	GameState.bench.append(unit)
	_shop_offer[i] = null
	_refresh_shop()
	_refresh_bench()


func _on_reroll_pressed() -> void:
	_cancel_sell()
	if RunManager.spend_gold(REROLL_COST):
		_roll_shop()


func _on_xp_pressed() -> void:
	RunManager.buy_xp()


func _on_bench_pressed(i: int) -> void:
	_cancel_sell()
	if RunManager.phase != RunManager.Phase.PREP:
		_hint_label.text = "Solo puedes colocar en preparación"
		_hint_label.visible = true
		return
	if i < GameState.bench.size():
		_placing_unit = GameState.bench[i]
		_hint_label.text = "Coloca %s en el pasto · clic derecho cancela" % _placing_unit.display_name
		_hint_label.visible = true


func _on_bench_gui_input(event: InputEvent, unit: TurretData) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_offer_sell({"kind": "bench", "unit": unit, "value": _sell_value(unit)})


func _on_hide_toggled(pressed: bool) -> void:
	_shop_box.visible = not pressed
	_bench_box.visible = not pressed
	_hide_button.text = "Mostrar tienda" if pressed else "Ocultar tienda"


# --- HUD + UI ---
func _build_hud() -> void:
	_round_label = _make_label(Vector2(16, 16))
	_hp_label = _make_label(Vector2(16, 44))
	_hero_hp_label = _make_label(Vector2(16, 72))
	_gold_label = _make_label(Vector2(16, 100))
	_level_label = _make_label(Vector2(16, 128))
	_hint_label = _make_label(Vector2(16, 160))
	_hint_label.visible = false
	_gold_label.text = "Oro: 0"
	_update_level_label()


func _make_label(pos: Vector2) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", 22)
	ui.add_child(l)
	return l


func _build_shop_ui() -> void:
	_bench_box = HBoxContainer.new()
	_bench_box.add_theme_constant_override("separation", 6)
	_anchor_row(_bench_box, -132.0, -96.0)
	ui.add_child(_bench_box)

	_shop_box = HBoxContainer.new()
	_shop_box.add_theme_constant_override("separation", 6)
	_anchor_row(_shop_box, -84.0, -12.0)
	ui.add_child(_shop_box)

	for i in 5:
		var b := Button.new()
		b.custom_minimum_size = Vector2(110, 64)
		b.pressed.connect(_on_slot_pressed.bind(i))
		_shop_box.add_child(b)
		_slot_buttons.append(b)

	var reroll := Button.new()
	reroll.text = "Reroll (%d)" % REROLL_COST
	reroll.custom_minimum_size = Vector2(90, 64)
	reroll.pressed.connect(_on_reroll_pressed)
	_shop_box.add_child(reroll)

	var xp := Button.new()
	xp.text = "XP (%d)" % RunManager.XP_COST
	xp.custom_minimum_size = Vector2(80, 64)
	xp.pressed.connect(_on_xp_pressed)
	_shop_box.add_child(xp)

	var start := Button.new()
	start.text = "▶ Empezar"
	start.custom_minimum_size = Vector2(110, 64)
	start.pressed.connect(RunManager.request_start_round)
	_shop_box.add_child(start)

	# botón de venta (aparece al hacer clic derecho sobre una unidad)
	_sell_button = Button.new()
	_sell_button.visible = false
	_sell_button.anchor_left = 0.5
	_sell_button.anchor_right = 0.5
	_sell_button.anchor_top = 1.0
	_sell_button.anchor_bottom = 1.0
	_sell_button.offset_left = -120.0
	_sell_button.offset_right = 120.0
	_sell_button.offset_top = -184.0
	_sell_button.offset_bottom = -144.0
	_sell_button.pressed.connect(_do_sell)
	ui.add_child(_sell_button)

	# botón ocultar/mostrar tienda (siempre visible, arriba a la derecha)
	_hide_button = Button.new()
	_hide_button.text = "Ocultar tienda"
	_hide_button.toggle_mode = true
	_hide_button.anchor_left = 1.0
	_hide_button.anchor_right = 1.0
	_hide_button.offset_left = -160.0
	_hide_button.offset_right = -12.0
	_hide_button.offset_top = 12.0
	_hide_button.offset_bottom = 48.0
	_hide_button.toggled.connect(_on_hide_toggled)
	ui.add_child(_hide_button)


## Ancla un Control horizontal abajo (ancho completo), con offsets top/bottom.
func _anchor_row(c: Control, top: float, bottom: float) -> void:
	c.anchor_left = 0.0
	c.anchor_right = 1.0
	c.anchor_top = 1.0
	c.anchor_bottom = 1.0
	c.offset_left = 12.0
	c.offset_right = -12.0
	c.offset_top = top
	c.offset_bottom = bottom


func _refresh_shop() -> void:
	for i in _slot_buttons.size():
		var b: Button = _slot_buttons[i]
		var unit: TurretData = _shop_offer[i] if i < _shop_offer.size() else null
		if unit == null:
			b.text = "—"
			b.disabled = true
			b.modulate = Color.WHITE
		else:
			b.text = "%s\n$%d" % [unit.display_name, _shop.unit_cost(unit)]
			b.disabled = false
			b.modulate = unit.body_color.lerp(Color.WHITE, 0.45)


func _refresh_bench() -> void:
	for child in _bench_box.get_children():
		child.queue_free()
	for i in GameState.bench.size():
		var unit: TurretData = GameState.bench[i]
		var b := Button.new()
		b.text = unit.display_name
		b.custom_minimum_size = Vector2(90, 36)
		b.modulate = unit.body_color.lerp(Color.WHITE, 0.45)
		b.pressed.connect(_on_bench_pressed.bind(i))
		b.gui_input.connect(_on_bench_gui_input.bind(unit))
		_bench_box.add_child(b)


func _update_level_label() -> void:
	var lvl := GameState.level
	var cap := GameState.board_capacity()
	if RunManager.is_max_level():
		_level_label.text = "Nivel %d (máx) · tablero %d" % [lvl, cap]
	else:
		_level_label.text = "Nivel %d · %d/%d · tablero %d" % [lvl, GameState.exp, RunManager.xp_needed(lvl), cap]


func _on_base_hp_changed(current: int, maximum: int) -> void:
	GameState.base_hp = current
	GameState.base_hp_max = maximum
	_hp_label.text = "Castillo: %d / %d" % [current, maximum]


func _on_hero_damaged(current: float, maximum: float) -> void:
	_hero_hp_label.text = "Héroe: %d / %d" % [int(current), int(maximum)]


func _on_gold_changed(amount: int) -> void:
	_gold_label.text = "Oro: %d" % amount


func _on_progress_changed(_v: int) -> void:
	_update_level_label()


func _on_phase_changed(phase: int) -> void:
	if phase == RunManager.Phase.PREP:
		_round_label.text = "Ronda %d — preparación" % (GameState.round_number + 1)
		_roll_shop()
	else:
		_cancel_placing()
		_cancel_sell()
		_round_label.text = "Ronda %d — ¡combate!" % GameState.round_number


# --- Oleadas ---
func _on_round_started(n: int) -> void:
	_wave_active = true
	_spawn_wave(n)


func _spawn_wave(n: int) -> void:
	_spawning = true
	_alive = 0
	var count := WAVE_BASE + n
	for i in count:
		if not _wave_active or not is_inside_tree():
			break
		_spawn_one()
		_alive += 1
		await get_tree().create_timer(SPAWN_GAP).timeout
	_spawning = false
	_check_wave_clear()


func _spawn_one() -> void:
	var follower := PathFollow2D.new()
	follower.loop = false
	enemy_path.add_child(follower)
	var slime: Slime = SlimeScene.instantiate()
	slime.position = Vector2(0, -64)
	follower.add_child(slime)


func _on_enemy_died(_enemy: Node, _bounty: int) -> void:
	_enemy_removed()


func _on_enemy_reached_castle(_damage: int) -> void:
	_enemy_removed()


func _enemy_removed() -> void:
	_alive -= 1
	_check_wave_clear()


func _check_wave_clear() -> void:
	if _wave_active and not _spawning and _alive <= 0:
		_wave_active = false
		EventBus.wave_cleared.emit(GameState.round_number)


func _on_run_ended(victory: bool) -> void:
	_wave_active = false
	_spawning = false
	_cancel_placing()
	_cancel_sell()
	if not victory:
		game_over_label.show()
