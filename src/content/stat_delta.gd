class_name StatDelta
extends Resource
## Un cambio puntual a un stat de CombatStats. Los Modifier agrupan varios.

enum Op { FLAT_ADD, PERCENT_ADD, PERCENT_MULT }

@export var stat: String = ""        ## nombre del campo en CombatStats (ej. "damage")
@export var op: Op = Op.FLAT_ADD
@export var value: float = 0.0
