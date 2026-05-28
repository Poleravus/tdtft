# Contribuir a tdtft

Bienvenido. Esta guía es corta a propósito — pensada para que quien toca código por primera vez no rompa nada.

## Flujo

1. Creá una rama desde `main`: `git checkout -b tipo/descripcion-corta` (ej. `feat/torreta-basica`, `fix/oro-negativo`).
2. Hacé tus cambios.
3. Escribí o actualizá tests si tocaste lógica.
4. Abrí un Pull Request. **El CI corre los tests automáticamente** — un PR no se mergea si los tests fallan.

## Dónde va cada cosa

- Lógica de juego → `src/` (ver el README de cada subcarpeta).
- La presentación (UI/escenas) **no** mete lógica de juego.
- Los sistemas se comunican vía `EventBus` (en `src/core/`), no se llaman directo entre sí.
- Contenido nuevo (un héroe, un aumento) = un `.tres` en `resources/` usando un molde de `src/content/`.

## Tests

- Archivos `test_*.gd` en `tests/unit/` o `tests/integration/`.
- Clases `extends GutTest`.
- Mirá `tests/unit/test_example.gd` como plantilla.
- Corré localmente (Godot en el PATH):
  ```
  godot --headless --script res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json
  ```

## Estilo

- GDScript con tipos estáticos donde se pueda (`var x: int`, `func f() -> void`).
- Nombres claros en vez de comentarios. Comentá solo el *por qué* cuando no sea obvio.
