class_name ShopConfig
extends Resource
## Reglas de autochess (tienda, niveles, pool, estrellas).
## TODOS los números son de ARRANQUE — pensados para tunear.

const MAX_STAR: int = 4          ## unidades de 1 a 4 estrellas
const COMBINE_COUNT: int = 3     ## 3 iguales -> sube de estrella

@export var shop_size: int = 5   ## unidades ofrecidas por tirada
@export var reroll_cost: int = 2
@export var max_level: int = 12

## Slots de tablero base por nivel (autochess: 1 por nivel). Índice = nivel-1.
@export var board_slots_by_level: PackedInt32Array = PackedInt32Array([
	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
])

## Copias en el pool por rareza [COMUN, RARA, EPICA, LEGENDARIA].
## Escasez estilo TFT: 4★ pide 27 copias (imposible en rarezas altas) y
## 3★ pide 9 (el reto duro para épica/legendaria).
@export var pool_per_unit: PackedInt32Array = PackedInt32Array([22, 16, 12, 10])

## Probabilidad por rareza según nivel (cada fila suma 1.0). Índice = nivel-1.
## [P(comun), P(rara), P(epica), P(legendaria)]
@export var odds_by_level: Array[PackedFloat32Array] = [
	PackedFloat32Array([1.00, 0.00, 0.00, 0.00]),  # nivel 1
	PackedFloat32Array([1.00, 0.00, 0.00, 0.00]),  # nivel 2
	PackedFloat32Array([0.85, 0.15, 0.00, 0.00]),  # nivel 3
	PackedFloat32Array([0.75, 0.25, 0.00, 0.00]),  # nivel 4
	PackedFloat32Array([0.65, 0.30, 0.05, 0.00]),  # nivel 5
	PackedFloat32Array([0.55, 0.33, 0.12, 0.00]),  # nivel 6
	PackedFloat32Array([0.45, 0.35, 0.18, 0.02]),  # nivel 7
	PackedFloat32Array([0.38, 0.35, 0.22, 0.05]),  # nivel 8
	PackedFloat32Array([0.30, 0.33, 0.27, 0.10]),  # nivel 9
	PackedFloat32Array([0.22, 0.32, 0.32, 0.14]),  # nivel 10
	PackedFloat32Array([0.16, 0.28, 0.36, 0.20]),  # nivel 11
	PackedFloat32Array([0.10, 0.25, 0.38, 0.27]),  # nivel 12
]
