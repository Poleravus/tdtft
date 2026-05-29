class_name CombatStats
extends Resource
## Bloque de stats de combate compartido por héroes, enemigos y unidades.
## Cada *Data lo contiene (composición); los modificadores apuntan aquí.
## Guarda valores BASE — los stats actuales se calculan en el actor
## aplicando los modificadores activos sobre estos.

@export var max_health: float = 100.0
@export var damage: float = 10.0
@export var resistance: float = 0.0      ## % de mitigación (10 = recibe 10% menos)
@export var penetration: float = 0.0     ## resta plana a la resistencia del objetivo
@export var attack_speed: float = 1.0    ## ataques por segundo
@export var attack_range: float = 64.0   ## px
@export var health_regen: float = 0.0    ## vida por segundo


## Daño final tras mitigación. Fórmula acordada:
## resist efectiva = clamp(resist - pen, -100, 100). A -100 el daño se duplica;
## a +100 el objetivo es inmune (nunca cura).
static func mitigate(raw: float, resistance: float, penetration: float) -> float:
	var eff := clampf(resistance - penetration, -100.0, 100.0)
	return raw * (1.0 - eff / 100.0)
