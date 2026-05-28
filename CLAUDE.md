# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Contexto para asistentes de IA trabajando en este repo.

## Qué es

**tdtft** — tower defense con mecánicas de TFT. Roguelite PvE single-player estilo Balatro, en **Godot 4.6** (GDScript). 2D (el Forward+/Jolt en `project.godot` es solo el default de Godot, no una decisión de 3D).

## Core loop

TD de camino: enemigos caminan hacia la base, el jugador coloca unidades/torretas. Combate auto-battle con habilidades/reposicionamiento activables. Entre rondas: economía, tienda, **aumentos** (eje central del diseño) y **héroes** (anclas de estrategia con income/pasivas/activa propios). Run termina a 0 HP de base. Progresión meta permanente entre runs.

## Comandos

**Correr tests (headless):**
```
godot --headless --script res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json
```

**Correr el juego localmente:** abrir el proyecto en Godot 4.6 y presionar Play. No hay build script; el CI exporta a Web con el preset `"Web"` via `export_presets.cfg`.

## Arquitectura

- `src/core/` — autoloads: `EventBus` (hub de señales), `GameState` (estado de la run), `RunManager` (orquesta fases), `MetaProgression` (guardado entre runs). **Hoy son stubs** — el dueño los diseña 1×1.
- `src/systems/` — lógica de juego (economía, tienda, combate, aumentos, oleadas). Se comunican entre sí **solo vía `EventBus`**, nunca referencias directas entre sistemas.
- `src/entities/` — actores: héroes, torretas, enemigos, base.
- `src/ui/` — HUD y menús. Lee estado via señales de `EventBus`; **no muta estado directamente**.
- `src/content/` = moldes (`Resource`); `resources/` = instancias `.tres`. Separación pensada para que agregar contenido sea trivial.

El `EventBus` desacopla sistemas (mantiene multiplayer posible a futuro, aunque no es el foco). Si supera ~40 señales, dividir en buses por dominio (CombatBus, EconomyBus, etc.).

## Prioridades

- **Testing y guardrails son primera clase**, no afterthought: contribuidores primerizos tocan el código y sus PRs se validan vía CI (GUT + build web). No romper el flujo de tests.
- Mantené la lógica desacoplada de la presentación.

## Convenciones de trabajo

- Alinear el diseño **antes** de escribir código. No adelantarse a implementar.
- Mantener la estructura a alto nivel; no crear granularidad que el gameplay aún no pide.
- Tests con GUT en `tests/`, archivos `test_*.gd`, `extends GutTest`.
- GDScript con tipado estático donde sea posible. Nombres claros sobre comentarios.
- Branches: `tipo/descripcion-corta` desde `main` (ej. `feat/economy-system`, `fix/wave-spawn`).
- Nuevo contenido (héroe, aumento): crear `.tres` en `resources/` usando el molde de `src/content/`.
