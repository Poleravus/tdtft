class_name Slime
extends CharacterBody2D
## Enemigo MVP: recorre el camino, recibe daño del héroe y, si llega al final,
## le pega al castillo. Se registra en el grupo "enemies" para que el héroe lo
## encuentre. (Stats como @export por ahora; luego vienen de EnemyData.)

@export var max_health: float = 30.0
@export var speed: float = 100.0
@export var damage_to_castle: int = 2

var health: float
var _prev_pos: Vector2
var _finished: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	animated_sprite.play("walk")
	_prev_pos = global_position
	var follower := get_parent() as PathFollow2D
	if follower != null:
		follower.rotates = false


func _process(delta: float) -> void:
	if _finished:
		return
	var follower := get_parent() as PathFollow2D
	if follower == null:
		return

	follower.progress += speed * delta

	var dir := global_position - _prev_pos
	if abs(dir.x) > 0.5:
		animated_sprite.flip_h = dir.x < 0.0
	_prev_pos = global_position

	if follower.progress_ratio >= 1.0:
		_reach_castle()


func take_damage(amount: float) -> void:
	if _finished:
		return
	health -= amount
	if health <= 0.0:
		_die()


func _die() -> void:
	_finished = true
	EventBus.enemy_died.emit(self)
	_free_follower()


func _reach_castle() -> void:
	_finished = true
	EventBus.enemy_reached_castle.emit(damage_to_castle)
	_free_follower()


func _free_follower() -> void:
	var follower := get_parent()
	if follower != null:
		follower.queue_free()
