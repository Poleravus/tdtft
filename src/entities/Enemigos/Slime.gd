class_name Slime
extends Enemy
## Slime: presentación (animación de caminar, volteo y flash rojo al recibir golpe).
## Toda la lógica de stats/movimiento/daño vive en Enemy.

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var _prev_pos: Vector2
var _hit_tween: Tween


func _on_ready() -> void:
	animated_sprite.play("walk")
	_prev_pos = global_position


func _on_move(_delta: float) -> void:
	var dir := global_position - _prev_pos
	if abs(dir.x) > 0.5:
		animated_sprite.flip_h = dir.x < 0.0
	_prev_pos = global_position


func _on_hit() -> void:
	# parpadeo rojo: feedback claro de que el golpe entró
	if _hit_tween != null and _hit_tween.is_valid():
		_hit_tween.kill()
	animated_sprite.modulate = Color(1.0, 0.35, 0.35)
	_hit_tween = create_tween()
	_hit_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.18)


func aim_point() -> Vector2:
	return animated_sprite.global_position  # centro visual del slime, no el origen del nodo
