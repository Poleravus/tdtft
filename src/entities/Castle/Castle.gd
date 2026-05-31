class_name Castle
extends Node2D
## Castillo MVP: tiene vida (la condición de derrota). Recibe daño cuando un
## enemigo llega al final del camino; a 0 HP termina la run.
##
## El castillo NO escribe en GameState: solo emite señales. Quien orquesta el
## nivel (Cristian1 / futuro RunManager) traduce esas señales a estado.
## El default de `max_health` lo sobrescribe el controlador del nivel.

@export var max_health: int = 20

var health: int


func _ready() -> void:
	health = max_health
	EventBus.enemy_reached_castle.connect(_on_enemy_reached_castle)
	EventBus.base_hp_changed.emit(health, max_health)


func _on_enemy_reached_castle(damage: int) -> void:
	if health <= 0:
		return
	health = maxi(0, health - damage)
	EventBus.base_hp_changed.emit(health, max_health)
	if health <= 0:
		EventBus.run_ended.emit(false)
