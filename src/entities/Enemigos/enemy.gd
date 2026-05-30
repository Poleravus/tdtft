class_name Enemy
extends CharacterBody2D
## Base de los enemigos que recorren el camino. Lee sus stats de EnemyData vía
## un CombatStatsComponent. Si el héroe entra en hero_aggro_range, lo ataca.
## Los subtipos (Slime, …) agregan presentación con los hooks _on_ready/_on_move/_on_hit.

@export var data: EnemyData

var combat := CombatStatsComponent.new()
var _finished: bool = false
var _hero_attack_cd: float = 0.0


func _ready() -> void:
	add_to_group("enemies")
	if data == null:
		push_warning("Enemy sin EnemyData asignado: %s" % name)
		set_physics_process(false)
		return
	combat.setup(data.stats, data.modifiers)
	var follower := get_parent() as PathFollow2D
	if follower != null:
		follower.rotates = false
	_on_ready()


func _physics_process(delta: float) -> void:
	if _finished:
		return
	var follower := get_parent() as PathFollow2D
	if follower == null:
		return

	follower.progress += data.move_speed * delta
	_on_move(delta)
	_try_attack_hero(delta)

	if follower.progress_ratio >= 1.0:
		_reach_castle()


func take_damage(raw: float, penetration: float) -> void:
	if _finished:
		return
	combat.take_damage(raw, penetration)
	if combat.is_dead():
		_die()
	else:
		_on_hit()  # feedback de golpe (lo implementan los subtipos)


## Punto al que el héroe apunta/dibuja (centro visual). Los subtipos lo ajustan.
func aim_point() -> Vector2:
	return global_position


## Si el héroe está dentro del rango de agresión, lo ataca según su cadencia.
func _try_attack_hero(delta: float) -> void:
	_hero_attack_cd -= delta
	if _hero_attack_cd > 0.0:
		return
	# Duck-typed a propósito: evita que Enemy dependa de la clase Hero. Hero ya
	# depende de Enemy; tiparlo aquí crearía una referencia cíclica.
	var hero := get_tree().get_first_node_in_group("hero") as Node2D
	if hero == null:
		return
	if global_position.distance_to(hero.global_position) <= data.hero_aggro_range:
		hero.call("take_damage", data.damage_to_hero, combat.current.penetration)
		_hero_attack_cd = 1.0 / maxf(0.01, combat.current.attack_speed)


func _die() -> void:
	_finished = true
	EventBus.enemy_died.emit(self)
	_free_follower()


func _reach_castle() -> void:
	_finished = true
	EventBus.enemy_reached_castle.emit(int(data.damage_to_castle))
	_free_follower()


func _free_follower() -> void:
	var follower := get_parent()
	if follower != null:
		follower.queue_free()


# --- Hooks para subtipos (presentación) ---
func _on_ready() -> void:
	pass


func _on_move(_delta: float) -> void:
	pass


func _on_hit() -> void:
	pass
