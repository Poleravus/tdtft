class_name EnemyData
extends Resource
## Molde de un enemigo que recorre el camino hacia el castillo.

@export var display_name: String = ""
@export var scene: PackedScene
@export var stats: CombatStats                ## vida, resist, vel/rango de ataque
@export var move_speed: float = 100.0
@export var damage_to_hero: float = 5.0
@export var damage_to_castle: float = 1.0     ## daño plano al castillo (sin resist)
@export var hero_aggro_range: float = 48.0    ## si el héroe entra, lo ataca; si no, sigue
@export var gold_reward: int = 2              ## oro que suelta al morir
@export var modifiers: Array[Modifier] = []
