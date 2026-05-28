extends Node
## GameState — fuente única de verdad del estado de la run en curso.
##
## Idea: guarda aquí lo que define la partida actual (héroe, oro, vida base,
## nivel, aumentos activos). Cuando algo cambie, notificar vía EventBus para
## que UI y sistemas reaccionen sin acoplarse a este nodo.

# Estado candidato (definir al construir el gameplay — NADA definitivo):
# var hero            # Resource del héroe elegido
# var round_number: int
# var base_hp_max: int
# var base_hp: int
# var gold: int
# var level: int
# var xp: int
# var active_augments: Array

# Métodos candidatos:
# func reset() -> void          # reiniciar al empezar una run
# func add_gold(amount: int)    # mutar estado + emitir EventBus.gold_changed
# func damage_base(amount: int) # mutar estado + emitir EventBus.base_hp_changed
