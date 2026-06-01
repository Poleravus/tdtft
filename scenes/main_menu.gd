extends Control
## Menú principal: Jugar (→ selección de héroe) y Salir.

func _ready() -> void:
	var cc := CenterContainer.new()
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(cc)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 18)
	cc.add_child(vb)

	var title := Label.new()
	title.text = "tdtft"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	vb.add_child(title)

	var play := _menu_button("Jugar")
	play.pressed.connect(_on_play)
	vb.add_child(play)

	var quit := _menu_button("Salir")
	quit.pressed.connect(_on_quit)
	vb.add_child(quit)


func _menu_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(240, 56)
	return b


func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/hero_select.tscn")


func _on_quit() -> void:
	get_tree().quit()
