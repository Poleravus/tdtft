class_name Hero
extends CharacterBody2D
## Héroe MVP: se mueve con clic izquierdo y auto-ataca al enemigo más cercano
## dentro de su rango. Recibe daño por contacto y revive tras morir.
## (Stats puestas aquí como @export para el MVP; luego vienen de HeroData.)

@export var max_health: float = 200.0
@export var health_regen: float = 10.0      ## vida por segundo
@export var move_speed: float = 220.0
@export var damage: float = 12.0
@export var attack_range: float = 130.0
@export var attack_speed: float = 1.2       ## ataques por segundo
@export var contact_dps: float = 8.0        ## daño/seg que recibe por enemigo pegado
@export var respawn_time: float = 3.0

var health: float
var _target_pos: Vector2
var _spawn_pos: Vector2
var _attack_cd: float = 0.0
var _dead: bool = false
var _respawn_cd: float = 0.0

# feedback visual del ataque (rayo amarillo)
var _beam_to: Vector2
var _beam_t: float = 0.0


func _ready() -> void:
	health = max_health
	_target_pos = global_position
	_spawn_pos = global_position


func _unhandled_input(event: InputEvent) -> void:
	if _dead:
		return
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_target_pos = get_global_mouse_position()


func _physics_process(delta: float) -> void:
	if _dead:
		_respawn_cd -= delta
		if _respawn_cd <= 0.0:
			_respawn()
		return

	# moverse hacia el punto clicado
	var to_target := _target_pos - global_position
	velocity = to_target.normalized() * move_speed if to_target.length() > 6.0 else Vector2.ZERO
	move_and_slide()

	# regeneración
	health = minf(max_health, health + health_regen * delta)

	# auto-ataque al más cercano en rango
	_attack_cd -= delta
	var enemy := _nearest_enemy()
	if enemy != null and _attack_cd <= 0.0:
		enemy.call("take_damage", damage)   # duck-typed para MVP (Slime y futuros enemigos)
		_attack_cd = 1.0 / attack_speed
		_beam_to = enemy.global_position
		_beam_t = 0.12

	# daño por contacto de enemigos pegados
	for node in get_tree().get_nodes_in_group("enemies"):
		var e := node as Node2D
		if e != null and global_position.distance_to(e.global_position) < 36.0:
			_take_damage(contact_dps * delta)

	if _beam_t > 0.0:
		_beam_t -= delta
		queue_redraw()


func _nearest_enemy() -> Node2D:
	var best: Node2D = null
	var best_d := attack_range
	for node in get_tree().get_nodes_in_group("enemies"):
		var e := node as Node2D
		if e == null:
			continue
		var d := global_position.distance_to(e.global_position)
		if d <= best_d:
			best_d = d
			best = e
	return best


func _take_damage(amount: float) -> void:
	if _dead:
		return
	health -= amount
	EventBus.hero_damaged.emit(health, max_health)
	if health <= 0.0:
		_die()


func _die() -> void:
	_dead = true
	health = 0.0
	visible = false
	_respawn_cd = respawn_time
	EventBus.hero_damaged.emit(0.0, max_health)
	EventBus.hero_died.emit()


func _respawn() -> void:
	_dead = false
	visible = true
	health = max_health
	global_position = _spawn_pos
	_target_pos = _spawn_pos
	EventBus.hero_damaged.emit(health, max_health)


func _draw() -> void:
	if _beam_t > 0.0:
		draw_line(Vector2.ZERO, to_local(_beam_to), Color.YELLOW, 2.0)
