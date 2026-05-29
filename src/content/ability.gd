class_name Ability
extends Resource
## Habilidad base (ataque básico, habilidad 1, definitiva).
## Subclasea y sobrescribe activate() por arquetipo (proyectil, dash, AoE…).
## Para pasivas usa un Modifier siempre activo, no una Ability.

@export var display_name: String = ""
@export var cooldown: float = 1.0
@export var mana_cost: float = 0.0
@export var cast_range: float = 64.0

func activate(_caster: Node, _context: Dictionary) -> void:
	pass
