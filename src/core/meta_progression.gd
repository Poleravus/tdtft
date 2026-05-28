extends Node
## MetaProgression — progreso permanente entre runs (el lado "roguelite").
##
## Idea: lo que persiste cuando una run termina (moneda meta, héroes y aumentos
## desbloqueados). Se guarda en disco (user://) y se carga al arrancar.

# const SAVE_PATH := "user://meta_progression.save"

# Estado candidato (definir al construir el gameplay — NADA definitivo):
# var meta_currency: int
# var unlocked_heroes: Array
# var unlocked_augments: Array

# Métodos candidatos:
# func _ready()         # load_progress() al arrancar
# func save_progress()  # serializar a JSON en SAVE_PATH (FileAccess)
# func load_progress()  # leer y parsear el JSON si existe
