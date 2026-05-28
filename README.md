# tdtft

Tower defense con mecánicas de TFT. Roguelite PvE single-player (estilo Balatro): runs, economía, héroes y **aumentos** que rompen la partida. Hecho en **Godot 4.6**.

## Concepto

Enemigos recorren un camino hacia tu base; colocás unidades/torretas para defenderla. Entre rondas comprás, mejorás y reposicionás. Elegís un **héroe** (ancla de estrategia: reroll, fast-9, economía, tank…) y vas tomando **aumentos** que cambian la run (p.ej. recibir daño temprano a cambio de economía extra). La run termina cuando la base llega a 0 HP. El progreso permanente desbloquea héroes y aumentos para futuras runs.

## Estructura

```
src/            Código GDScript
  core/         Singletons globales (EventBus, GameState, RunManager, MetaProgression)
  systems/      Sistemas de juego (economía, tienda, oleadas, combate, aumentos)
  entities/     Héroes, torretas, enemigos, base
  content/      Moldes de datos (Resource): Hero, Augment, Wave…
  ui/           HUD, menús, pantallas
scenes/         Escenas .tscn de alto nivel
resources/      Instancias .tres de contenido
assets/         Sprites y audio (placeholders por ahora)
tests/          Tests con GUT (unit/ e integration/)
addons/gut/     Framework de tests (vendoreado)
```

Cada carpeta tiene un `README.md` con su propósito.

## Correr el juego

Abrir el proyecto en Godot 4.6 y darle Play. Plataforma primaria: desktop (Windows + macOS). Existe un build web (CI) que alimenta el pipeline de code-review.

## Tests

Los tests usan [GUT](https://github.com/bitwes/Gut) y corren en CI en cada PR. Localmente, con Godot en el PATH:

```
godot --headless --script res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json
```

Convención: archivos `test_*.gd` en `tests/`, clases `extends GutTest`. Ver `CONTRIBUTING.md`.
