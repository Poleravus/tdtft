extends Control
## Selección de héroe: muestra los disponibles; al elegir, guarda el molde en
## GameState y carga el nivel.

const HEROES := [
	preload("res://resources/heroes/hero_mvp.tres"),
	preload("res://resources/heroes/hero_tanque.tres"),
]


func _ready() -> void:
	var cc := CenterContainer.new()
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(cc)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	cc.add_child(vb)

	var title := Label.new()
	title.text = "Elige tu héroe"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	vb.add_child(title)

	for h in HEROES:
		var b := Button.new()
		b.text = "%s\nVida %d · Daño %d · Rango %d" % [h.display_name, int(h.stats.max_health), int(h.stats.damage), int(h.stats.attack_range)]
		b.custom_minimum_size = Vector2(380, 76)
		b.pressed.connect(_on_hero.bind(h))
		vb.add_child(b)

	var back := Button.new()
	back.text = "Volver"
	back.custom_minimum_size = Vector2(380, 44)
	back.pressed.connect(_on_back)
	vb.add_child(back)


func _on_hero(hero) -> void:
	GameState.selected_hero = hero
	get_tree().change_scene_to_file("res://scenes/Cristian1.tscn")


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
