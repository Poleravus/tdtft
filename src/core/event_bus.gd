extends Node
## EventBus — hub de señales global para desacoplar sistemas.
## Los sistemas emiten/escuchan aquí en vez de referenciarse entre sí.
## La UI lee de aquí; no muta estado directamente.
##
## NOTA (escalabilidad): si esto crece (~40 señales), partir por dominio:
## CombatBus, EconomyBus, RunBus. Por ahora un solo bus está bien.

# --- Ciclo de la run / fases ---
signal run_started
signal run_ended(victory: bool)
signal round_started(round_number: int)
signal round_ended(round_number: int)
signal phase_changed(phase: int)
signal time_tick(elapsed: float)
signal universe_selected(universe: Universe)
signal difficulty_changed(level: int)

# --- Economía / progresión ---
signal gold_changed(amount: int)
signal exp_changed(current: int)
signal level_changed(level: int)
signal base_hp_changed(current: int, maximum: int)

# --- Combate ---
signal enemy_spawned(enemy: Node)
signal enemy_died(enemy: Node, bounty: int)
signal enemy_reached_castle(damage: int)
signal wave_cleared(round_number: int)
signal hero_damaged(current: float, maximum: float)
signal hero_died
signal hero_ability_used(ability: Ability)

# --- Autochess: tienda / banca / tablero ---
signal shop_rerolled(offer: Array)
signal unit_bought(unit: TurretData)
signal unit_sold(unit: TurretData)
signal unit_combined(unit: TurretData, new_star: int)
signal unit_placed(unit: TurretData)
signal shop_quality_changed(odds: PackedFloat32Array)

# --- Aumentos / sinergias ---
signal augment_offered(options: Array)
signal augment_chosen(augment: Augment)
signal trait_activated(trait_def: Trait, tier: int)
