class_name Modifier
extends Resource
## Efecto componible que se adjunta a una entidad (o global vía Universe).
## Hoy: lista de cambios de stat (100% data-driven).
## Puerta abierta: un hook por evento para efectos con lógica
## (ej. "al matar, +1 oro") — se conectará cuando el gameplay lo pida.

@export var display_name: String = ""
@export var deltas: Array[StatDelta] = []

## Disparador opcional para efectos scripteados (vacío = solo deltas).
## Ej. "on_attack", "on_kill", "on_round_start". Sin uso todavía.
@export var trigger: String = ""
