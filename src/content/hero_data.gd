class_name HeroData
extends Resource
## Molde de un héroe (ancla controlable por el jugador, no sale en la tienda).

@export var display_name: String = ""
@export var scene: PackedScene                ## actor a instanciar
@export var stats: CombatStats
@export var max_mana: float = 100.0
@export var move_speed: float = 200.0
@export var size: float = 1.0                 ## escala + hitbox
@export var basic_attack: Ability
@export var passive: Modifier                 ## pasiva = modificador siempre activo
@export var ability_1: Ability
@export var ultimate: Ability
