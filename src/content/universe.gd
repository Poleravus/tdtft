class_name Universe
extends Resource
## "Universo" de la run: modificador global de la partida (estilo set de TFT).
## Muy global; no toca los pools de unidades.

@export var display_name: String = ""
@export_multiline var description: String = ""
@export var global_modifiers: Array[Modifier] = []   ## ej. +vida global, "siempre de noche"
@export var augment_round_offset: int = 0            ## ofrecer aumentos N rondas antes
@export var augment_quality_bonus: float = 0.0       ## sesga la calidad de los aumentos
