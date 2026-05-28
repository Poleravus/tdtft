# src/ — Código del juego

Toda la lógica en GDScript, organizada en alto nivel:

- **core/** — singletons globales (autoloads): estado, hub de señales, orquestación de run, progresión meta.
- **systems/** — sistemas de juego (economía, tienda, spawning de oleadas, combate, aumentos).
- **entities/** — actores del juego (héroes, torretas/unidades, enemigos, base).
- **content/** — clases base (`Resource`) que definen los "moldes" del contenido (un Hero, un Augment, una Wave…).
- **ui/** — interfaz: HUD, menús, pantallas de tienda/aumentos.

Regla: la lógica de juego no depende de la presentación. Los sistemas se comunican vía `EventBus` (en `core/`).
