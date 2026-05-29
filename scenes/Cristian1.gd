extends Node2D
## Controlador del nivel MVP: instancia castillo + héroe, lanza oleadas de
## slimes y maneja el HUD y el game over vía EventBus.

const SlimeScene := preload("res://src/entities/Enemigos/Slime.tscn")
const HeroScene := preload("res://src/entities/Hero/Hero.tscn")
const CastleScene := preload("res://src/entities/Castle/Castle.tscn")

const WAVE_SIZE: int = 5
const WAVE_INTERVAL: float = 10.0
const SPAWN_GAP: float = 0.6     ## segundos entre cada slime de la oleada
const CASTLE_HP: int = 20

@onready var enemy_path: Path2D = $CaminoEnemigo
@onready var ui: CanvasLayer = $UI
@onready var game_over_label: Label = $UI/GameOverLabel

var _wave_timer: Timer
var _hp_label: Label
var _hero_hp_label: Label
var _castle: Castle
var _hero: Hero
var _spawning: bool = true


func _ready() -> void:
	game_over_label.hide()
	GameState.reset()

	_spawn_castle_and_hero()
	_build_hud()

	EventBus.base_hp_changed.connect(_on_base_hp_changed)
	EventBus.hero_damaged.connect(_on_hero_damaged)
	EventBus.run_ended.connect(_on_run_ended)

	_wave_timer = Timer.new()
	_wave_timer.wait_time = WAVE_INTERVAL
	_wave_timer.timeout.connect(_spawn_wave)
	add_child(_wave_timer)
	_wave_timer.start()
	_spawn_wave()


func _spawn_castle_and_hero() -> void:
	var curve := enemy_path.curve
	var end_global := enemy_path.to_global(curve.get_point_position(curve.point_count - 1))
	var start_global := enemy_path.to_global(curve.get_point_position(0))

	_castle = CastleScene.instantiate()
	_castle.max_health = CASTLE_HP
	add_child(_castle)
	_castle.global_position = end_global

	_hero = HeroScene.instantiate()
	add_child(_hero)
	_hero.global_position = start_global.lerp(end_global, 0.5)  # a medio camino


func _build_hud() -> void:
	_hp_label = _make_label(Vector2(16, 16))
	_hero_hp_label = _make_label(Vector2(16, 44))
	_update_hp_label(GameState.base_hp, GameState.base_hp_max)
	_on_hero_damaged(_hero.health, _hero.max_health)


func _make_label(pos: Vector2) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", 22)
	ui.add_child(label)
	return label


func _spawn_wave() -> void:
	for i in WAVE_SIZE:
		if not _spawning or not is_inside_tree():
			return
		_spawn_one()
		await get_tree().create_timer(SPAWN_GAP).timeout


func _spawn_one() -> void:
	var follower := PathFollow2D.new()
	follower.loop = false
	enemy_path.add_child(follower)

	var slime: Slime = SlimeScene.instantiate()
	slime.position = Vector2(0, -64)
	follower.add_child(slime)


func _on_base_hp_changed(current: int, maximum: int) -> void:
	_update_hp_label(current, maximum)


func _update_hp_label(current: int, maximum: int) -> void:
	_hp_label.text = "Castillo: %d / %d" % [current, maximum]


func _on_hero_damaged(current: float, maximum: float) -> void:
	_hero_hp_label.text = "Héroe: %d / %d" % [int(current), int(maximum)]


func _on_run_ended(victory: bool) -> void:
	_spawning = false
	_wave_timer.stop()
	if not victory:
		game_over_label.show()
