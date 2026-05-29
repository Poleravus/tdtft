class_name Augment
extends Resource
## Aumento: elección de run (eje del diseño). Se ofrece entre rondas.

@export var display_name: String = ""
@export var rarity: Rarity.Tier = Rarity.Tier.COMUN
@export var tags: Array[String] = []           ## casa con CastleData.preferred_augment_tags
@export var modifiers: Array[Modifier] = []     ## qué otorga
