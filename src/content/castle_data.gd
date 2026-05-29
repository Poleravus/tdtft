class_name CastleData
extends Resource
## Molde del castillo/imperio. La economía viva (oro/exp/vida actual) está en
## GameState; aquí va solo la CONFIG del imperio elegido.

@export var display_name: String = ""
@export var max_health: int = 100
@export var passive_gold: float = 0.0         ## oro pasivo por ronda
@export var passive_exp: float = 0.0          ## exp pasiva por ronda
@export var passive_heal: float = 0.0         ## vida recuperada por ronda
@export var board_slot_bonus: int = 0         ## slots extra SOBRE el base por nivel
@export var preferred_augment_tags: Array[String] = []
