extends Node
## EventBus — hub de señales global para desacoplar sistemas.
##
## Idea: los sistemas emiten/escuchan señales acá en vez de referenciarse
## entre sí. Mantener el core desacoplado deja la puerta abierta a multiplayer.
##
## NOTA (escalabilidad): si esto crece a muchas señales (~40), conviene
## partirlo por dominio en buses separados, p.ej.:
##   CombatBus  -> oleadas, daño, muertes
##   EconomyBus -> oro, tienda, nivel/xp
##   RunBus     -> inicio/fin de run, fases, aumentos
## Por ahora un solo bus está bien.

# Señales candidatas (definir cuando el gameplay las pida — NADA definitivo):
# --- Ciclo de la run ---
# signal run_started
# signal run_ended(victory: bool)
# --- Ronda / fases ---
# signal round_started(round_number: int)
# signal phase_changed(phase: int)
# --- Economía / progresión ---
# signal gold_changed(amount: int)
# signal level_changed(level: int)
# signal base_hp_changed(current: int, maximum: int)
# --- Combate ---
# signal wave_spawned(round_number: int)
# signal enemy_reached_base(damage: int)
# signal wave_cleared(round_number: int)
# --- Aumentos ---
# signal augment_offered(options: Array)
# signal augment_chosen(augment)
