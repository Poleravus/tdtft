extends Node2D
## Controlador del nivel: castillo + héroe, oleadas (pide RunManager), HUD, y en
## PREP la tienda + colocación de torretas (solo sobre Mapa, nunca en el camino).
## RunManager lleva las fases y la economía.

const SlimeScene := preload("res://src/entities/Enemigos/Slime.tscn")
const HeroScene := preload("res://src/entities/Hero/Hero.tscn")
const CastleScene := preload("res://src/entities/Castle/Castle.tscn")
const TurretScene := preload("res://src/entities/Torretas/Turret.tscn")

const WAVE_BASE: int = 4          ## oleada de la ronda N = WAVE_BASE + N slimes
const SPAWN_GAP: float = 0.6
const CASTLE_HP: int = 20
const ARCHER_COST: int = 10

@onready var enemy_path: Path2D = $CaminoEnemigo
@onready var camino: TileMapLayer = $Camino
@onready var mapa: TileMapLayer = $Mapa
@onready var ui: CanvasLayer = $UI
@onready var game_over_label: Label = $UI/GameOverLabel

var _castle: Castle
var _hero: Hero

var _round_label: Label
var _hp_label: Label
var _hero_hp_label: Label
var _gold_label: Label
var _level_label: Label
var _hint_label: Label
var _start_button: Button
var _auto_check: CheckButton
var _shop_button: Button

var _alive: int = 0
var _spawning: bool = false
var _wave_active: bool = false

var _placing: bool = false
var _occupied: Dictionary = {}   ## celda (Vector2i) -> ocupada por torreta


func _ready() -> void:
	game_over_label.hide()
	_build_hud()
	_build_controls()

	EventBus.base_hp_changed.connect(_on_base_hp_changed)
	EventBus.hero_damaged.connect(_on_hero_damaged)
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.level_changed.connect(_on_level_changed)
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
	# sobre el camino, a la mitad del recorrido real
	_hero.global_position = enemy_path.to_global(curve.sample_baked(curve.get_baked_length() * 0.5))


# --- Colocación de torretas (modo placing en PREP) ---
func _input(event: InputEvent) -> void:
	if not _placing:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_place(get_global_mouse_position())
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_set_placing(false)  # cancelar
			get_viewport().set_input_as_handled()


func _try_place(world_pos: Vector2) -> void:
	if not _can_build_at(world_pos):
		return  # punto inválido: seguimos en modo placing
	if not RunManager.spend_gold(ARCHER_COST):
		_set_placing(false)
		return
	var cell := mapa.local_to_map(mapa.to_local(world_pos))
	var turret := TurretScene.instantiate()
	add_child(turret)
	turret.global_position = mapa.to_global(mapa.map_to_local(cell))
	_occupied[cell] = true
	_set_placing(false)


## Se puede construir si hay suelo (Mapa), NO hay camino y la celda está libre.
func _can_build_at(world_pos: Vector2) -> bool:
	var camino_cell := camino.local_to_map(camino.to_local(world_pos))
	if camino.get_cell_source_id(camino_cell) != -1:
		return false
	var mapa_cell := mapa.local_to_map(mapa.to_local(world_pos))
	if mapa.get_cell_source_id(mapa_cell) == -1:
		return false
	return not _occupied.has(mapa_cell)


func _set_placing(on: bool) -> void:
	_placing = on
	_hint_label.visible = on


func _on_shop_pressed() -> void:
	if RunManager.phase == RunManager.Phase.PREP and RunManager.can_afford(ARCHER_COST):
		_set_placing(true)


# --- HUD + controles (creados por código) ---
func _build_hud() -> void:
	_round_label = _make_label(Vector2(16, 16))
	_hp_label = _make_label(Vector2(16, 44))
	_hero_hp_label = _make_label(Vector2(16, 72))
	_gold_label = _make_label(Vector2(16, 100))
	_level_label = _make_label(Vector2(16, 128))
	_gold_label.text = "Oro: 0"
	_level_label.text = "Nivel: 1"

	_hint_label = _make_label(Vector2(16, 160))
	_hint_label.text = "Clic en pasto para colocar · clic derecho cancela"
	_hint_label.visible = false


func _make_label(pos: Vector2) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", 22)
	ui.add_child(label)
	return label


func _build_controls() -> void:
	_shop_button = Button.new()
	_shop_button.text = "Comprar Arquero (%d)" % ARCHER_COST
	_anchor_bottom(_shop_button, 20.0, 220.0)
	_shop_button.pressed.connect(_on_shop_pressed)
	ui.add_child(_shop_button)

	_start_button = Button.new()
	_start_button.text = "▶ Empezar"
	_anchor_bottom(_start_button, 260.0, 140.0)
	_start_button.pressed.connect(RunManager.request_start_round)
	ui.add_child(_start_button)

	_auto_check = CheckButton.new()
	_auto_check.text = "Auto"
	_auto_check.button_pressed = RunManager.auto_start
	_anchor_bottom(_auto_check, 410.0, 130.0)
	_auto_check.toggled.connect(RunManager.set_auto_start)
	ui.add_child(_auto_check)


## Ancla un Control abajo a la izquierda, con offset x y ancho dados.
func _anchor_bottom(c: Control, x: float, width: float) -> void:
	c.anchor_top = 1.0
	c.anchor_bottom = 1.0
	c.offset_left = x
	c.offset_right = x + width
	c.offset_top = -56.0
	c.offset_bottom = -16.0


func _on_base_hp_changed(current: int, maximum: int) -> void:
	GameState.base_hp = current
	GameState.base_hp_max = maximum
	_hp_label.text = "Castillo: %d / %d" % [current, maximum]


func _on_hero_damaged(current: float, maximum: float) -> void:
	_hero_hp_label.text = "Héroe: %d / %d" % [int(current), int(maximum)]


func _on_gold_changed(amount: int) -> void:
	_gold_label.text = "Oro: %d" % amount
	_shop_button.disabled = amount < ARCHER_COST


func _on_level_changed(level: int) -> void:
	_level_label.text = "Nivel: %d" % level


func _on_phase_changed(phase: int) -> void:
	var in_prep := phase == RunManager.Phase.PREP
	_shop_button.visible = in_prep
	_start_button.visible = in_prep
	_auto_check.visible = in_prep
	if not in_prep:
		_set_placing(false)
		_round_label.text = "Ronda %d — ¡combate!" % GameState.round_number
	else:
		_round_label.text = "Ronda %d — preparación" % (GameState.round_number + 1)


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
	slime.position = Vector2(0, -64)  # centra el sprite del slime sobre el punto del path
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
	_set_placing(false)
	if not victory:
		game_over_label.show()
