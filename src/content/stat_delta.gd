class_name StatDelta
extends Resource
## Un cambio puntual a un stat de CombatStats. Los Modifier agrupan varios.
##
## OJO: `stat` debe coincidir EXACTAMENTE con el nombre de un campo de
## CombatStats (ej. "damage", "attack_speed"). Si renombras un campo allá, los
## .tres con el nombre viejo fallan en silencio. Con más campos conviene migrar
## a un enum StatType para que el editor lo valide.

enum Op { FLAT_ADD, PERCENT_ADD, PERCENT_MULT }

@export var stat: String = ""        ## nombre EXACTO de un campo de CombatStats (ej. "damage")
@export var op: Op = Op.FLAT_ADD
@export var value: float = 0.0
