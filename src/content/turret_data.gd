class_name TurretData
extends Resource
## Molde de una unidad de tienda (autochess). Se compra, va a la banca y se
## coloca en el tablero. 3 iguales se fusionan a la estrella siguiente (1→4).

@export var display_name: String = ""
@export var scene: PackedScene
@export var stats: CombatStats                ## daño, vel ataque, rango
@export_enum("Single", "AoE", "Chain", "DoT") var attack_type: int = 0
@export var splash_radius: float = 0.0                 ## >0 = daño en área (bombardero)
@export var body_color: Color = Color(0.3, 0.8, 0.3)  ## color del cuadrado (placeholder)
@export var rarity: Rarity.Tier = Rarity.Tier.COMUN
@export var traits: Array[Trait] = []         ## sinergias
@export var star_stat_multiplier: float = 1.8 ## stats ×este factor por cada estrella

## --- Invocación (opcional; una torre de daño deja esto vacío) ---
@export var summons: PackedScene              ## qué invoca (ej. Soldado)
@export var summon_count: int = 0
@export var summon_interval: float = 0.0
@export var max_active_summons: int = 0
