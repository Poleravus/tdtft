# CLAUDE.md

Contexto para asistentes de IA trabajando en este repo.

## Qué es

**tdtft** — tower defense con mecánicas de TFT. Roguelite PvE single-player estilo Balatro, en **Godot 4.6** (GDScript). 2D (el Forward+/Jolt en `project.godot` es solo el default de Godot, no una decisión de 3D).

## Core loop

TD de camino: enemigos caminan hacia la base, el jugador coloca unidades/torretas. Combate auto-battle con habilidades/reposicionamiento activables. Entre rondas: economía, tienda, **aumentos** (eje central del diseño) y **héroes** (anclas de estrategia con income/pasivas/activa propios). Run termina a 0 HP de base. Progresión meta permanente entre runs.

## Arquitectura

- `src/core/` — autoloads: `EventBus` (hub de señales), `GameState` (estado de la run), `RunManager` (orquesta fases), `MetaProgression` (guardado entre runs). **Hoy son stubs** — el dueño los diseña 1×1.
- Sistemas desacoplados vía `EventBus` (mantiene multiplayer posible a futuro, aunque no es el foco).
- `content/` = moldes (`Resource`); `resources/` = instancias `.tres`. Separación pensada para que agregar contenido sea trivial.

## Prioridades

- **Testing y guardrails son primera clase**, no afterthought: contribuidores primerizos tocan el código y sus PRs se validan vía CI (GUT + build web). No romper el flujo de tests.
- Mantené la lógica desacoplada de la presentación.

## Convenciones de trabajo

- Alinear el diseño **antes** de escribir código. No adelantarse a implementar.
- Mantener la estructura a alto nivel; no crear granularidad que el gameplay aún no pide.
- Tests con GUT en `tests/`, archivos `test_*.gd`, `extends GutTest`.
