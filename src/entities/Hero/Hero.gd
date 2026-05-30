class_name Hero
extends CharacterBody2D
## Héroe MVP: se mueve con clic izquierdo (velocidad instantánea, sin chocar con
## los enemigos) y auto-ataca a UN enemigo a la vez: el más cercano en rango.
## Stats desde HeroData (vía CombatStatsComponent).

@export var data: HeroData
@export var respawn_time: float = 3.0

const ATTACK_SPEED_PER_LEVEL: float = 0.08  ## +8% vel. de ataque por nivel del jugador

var combat := CombatStatsComponent.new()
var _target_pos: Vector2
var _spawn_pos: Vector2
var _spawn_set: bool = false
var _attack_cd: float = 0.0
var _dead: bool = false
var _respawn_cd: float = 0.0

# feedback visual del disparo (rayo + marca de impacto)
var _beam_to: Vector2
var _beam_t: float = 0.0


func _ready() -> void:
	collision_mask = 0  # el combate es por distancia; no chocar físicamente con nada
	if data == null:
		push_warning("Hero sin HeroData asignado: %s" % name)
		set_physics_process(false)
		return
	add_to_group("hero")
	EventBus.level_changed.connect(_on_level_up)
	combat.health_changed.connect(_on_health_changed)
	combat.died.connect(_on_died)
	combat.setup(data.stats, _build_modifiers())


func _build_modifiers() -> Array[Modifier]:
	var mods: Array[Modifier] = []
	if data.passive != null:
		mods.append(data.passive)
	return mods


## Cada nivel del jugador le suma velocidad de ataque al héroe (vía el pipeline
## de modificadores: cada subida añade un +% acumulable).
func _on_level_up(_level: int) -> void:
	var d := StatDelta.new()
	d.stat = "attack_speed"
	d.op = StatDelta.Op.PERCENT_ADD
	d.value = ATTACK_SPEED_PER_LEVEL
	var m := Modifier.new()
	m.deltas.append(d)
	combat.add_modifier(m)


func _unhandled_input(event: InputEvent) -> void:
	if _dead:
		return
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_target_pos = get_global_mouse_position()


func take_damage(raw: float, penetration: float) -> void:
	if _dead:
		return
	combat.take_damage(raw, penetration)


func _physics_process(delta: float) -> void:
	# capturar spawn/target una vez que el controlador ya posicionó al héroe
	if not _spawn_set:
		_spawn_pos = global_position
		_target_pos = global_position
		_spawn_set = true

	if _dead:
		_respawn_cd -= delta
		if _respawn_cd <= 0.0:
			_respawn()
		return

	# movimiento hacia el punto clicado (velocidad instantánea)
	var to_target := _target_pos - global_position
	velocity = to_target.normalized() * data.move_speed if to_target.length() > 6.0 else Vector2.ZERO
	move_and_slide()

	combat.heal(combat.current.health_regen * delta)

	# auto-ataque a UN solo enemigo: el más cercano en rango
	_attack_cd -= delta
	var nearest := _nearest_enemy_in_range()
	if nearest != null and _attack_cd <= 0.0:
		nearest.take_damage(combat.current.damage, combat.current.penetration)
		_attack_cd = 1.0 / combat.current.attack_speed
		_beam_to = nearest.aim_point()
		_beam_t = 0.14

	if _beam_t > 0.0:
		_beam_t -= delta
		queue_redraw()


func _nearest_enemy_in_range() -> Enemy:
	var best: Enemy = null
	var best_d := combat.current.attack_range
	for node in get_tree().get_nodes_in_group("enemies"):
		var e := node as Enemy
		if e == null:
			continue
		var d := global_position.distance_to(e.aim_point())
		if d <= best_d:
			best_d = d
			best = e
	return best


func _on_health_changed(current: float, maximum: float) -> void:
	EventBus.hero_damaged.emit(current, maximum)


func _on_died() -> void:
	if _dead:
		return
	_dead = true
	visible = false
	_respawn_cd = respawn_time
	EventBus.hero_died.emit()


func _respawn() -> void:
	_dead = false
	visible = true
	combat.full_heal()
	global_position = _spawn_pos
	_target_pos = _spawn_pos


func _draw() -> void:
	if _beam_t <= 0.0:
		return
	var end := to_local(_beam_to)
	draw_line(Vector2.ZERO, end, Color.YELLOW, 3.0)
	draw_circle(end, 5.0, Color.ORANGE)  # marca de impacto
