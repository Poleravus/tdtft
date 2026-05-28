extends Node
## RunManager — orquesta el flujo de una run.
##
## Idea: maneja la transición entre fases de cada ronda y el inicio/fin de la
## run. No guarda el estado (eso es GameState); solo lo coordina y avisa por
## EventBus.

# Fases candidatas (definir al construir el gameplay — NADA definitivo):
# enum Phase { PLANNING, COMBAT, RESULT }
# var phase: int

# Métodos candidatos:
# func start_run()        # reset + EventBus.run_started + primera ronda
# func _begin_round()     # avanza ronda, fase PLANNING
# func start_combat()     # fase COMBAT, dispara la oleada
# func end_run(victory)   # fase RESULT, EventBus.run_ended
